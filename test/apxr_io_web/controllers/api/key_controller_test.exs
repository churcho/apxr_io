defmodule ApxrIoWeb.API.KeyControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIo.Repo
  alias ApxrIo.Accounts.{AuditLog, Key, KeyPermission}

  setup do
    eric = create_user("eric", "eric@mail.com")
    other = create_user("other", "other@mail.com")
    team = insert(:team)
    unowned_team = insert(:team)
    insert(:team_user, team: team, user: eric)

    %{
      team: team,
      unowned_team: unowned_team,
      eric: eric,
      other: other
    }
  end

  describe "GET /api/keys" do
    test "all keys", c do
      Key.build(c.eric, %{name: "macbook"}) |> Repo.insert!()
      key = Key.build(c.eric, %{name: "computer"}) |> Repo.insert!()

      body =
        build_conn()
        |> put_req_header("authorization", key.user_secret)
        |> get("api/keys")
        |> json_response(200)
        |> Enum.sort_by(fn %{"name" => name} -> name end)

      assert length(body) == 2
      [a, b] = body
      assert a["name"] == "computer"
      assert a["secret"] == nil
      assert a["authing_key"]
      assert b["name"] == "macbook"
      # inserted_at ISO8601 datetime string should include a Z to indicate UTC
      assert String.slice(b["inserted_at"], -1, 1) == "Z"
      assert b["secret"] == nil
      refute b["authing_key"]
    end

    test "key authorizes", c do
      key = Key.build(c.eric, %{name: "macbook"}) |> Repo.insert!()

      conn =
        build_conn()
        |> put_req_header("authorization", key.user_secret)
        |> get("api/keys")

      body = json_response(conn, 200)
      assert length(body) == 1

      build_conn()
      |> put_req_header("authorization", "wrong")
      |> get("api/keys")
      |> json_response(401)
    end
  end

  describe "GET api/teams/:team/keys" do
    test "all keys", c do
      Key.build(c.team, %{name: "macbook"}) |> Repo.insert!()
      team_key = Key.build(c.team, %{name: "computer"}) |> Repo.insert!()
      user_key = Key.build(c.eric, %{name: "computer"}) |> Repo.insert!()

      body =
        build_conn()
        |> put_req_header("authorization", team_key.user_secret)
        |> get("api/teams/#{c.team.name}/keys")
        |> json_response(200)

      assert length(body) == 2

      body =
        build_conn()
        |> put_req_header("authorization", user_key.user_secret)
        |> get("api/teams/#{c.team.name}/keys")
        |> json_response(200)

      assert length(body) == 2
    end

    test "key authorizes", c do
      team_key = Key.build(c.team, %{name: "computer"}) |> Repo.insert!()
      eric_key = Key.build(c.eric, %{name: "computer"}) |> Repo.insert!()
      other_key = Key.build(c.other, %{name: "computer"}) |> Repo.insert!()

      build_conn()
      |> put_req_header("authorization", team_key.user_secret)
      |> get("api/teams/#{c.unowned_team.name}/keys")
      |> json_response(403)

      build_conn()
      |> put_req_header("authorization", eric_key.user_secret)
      |> get("api/teams/#{c.unowned_team.name}/keys")
      |> json_response(403)

      build_conn()
      |> put_req_header("authorization", other_key.user_secret)
      |> get("api/teams/#{c.team.name}/keys")
      |> json_response(403)

      build_conn()
      |> put_req_header("authorization", "wrong")
      |> get("api/teams/#{c.team.name}/keys")
      |> json_response(401)

      build_conn()
      |> get("api/teams/#{c.team.name}/keys")
      |> json_response(401)
    end
  end

  describe "POST /api/keys" do
    test "create api key", c do
      body = %{name: "macbook"}

      conn =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> put_req_header("authorization", key_for(c.eric))
        |> put_req_header("authorization", key_for(c.eric))
        |> post("api/keys", Jason.encode!(body))

      assert conn.status == 201
      key = Repo.one!(Key.get(c.eric, "macbook"))
      assert [%KeyPermission{domain: "api"}] = key.permissions

      log = Repo.one!(AuditLog)
      assert log.user_id == c.eric.id
      assert log.action == "key.generate"
      assert %{"name" => "macbook"} = log.params
    end

    test "create repository key", c do
      body = %{
        name: "macbook",
        permissions: [%{domain: "repository", resource: c.team.name}]
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", key_for(c.eric))
      |> post("api/keys", Jason.encode!(body))
      |> json_response(201)

      key = Repo.one!(Key.get(c.eric, "macbook"))
      repo_name = c.team.name
      assert [%KeyPermission{domain: "repository", resource: ^repo_name}] = key.permissions
    end

    test "create repository key with api key", c do
      key = Key.build(c.eric, %{name: "computer"}) |> Repo.insert!()

      body = %{
        name: "macbook",
        permissions: [%{domain: "repository", resource: c.team.name}]
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", key.user_secret)
      |> post("api/keys", Jason.encode!(body))
      |> json_response(201)

      key = Repo.one!(Key.get(c.eric, "macbook"))
      repo_name = c.team.name
      assert [%KeyPermission{domain: "repository", resource: ^repo_name}] = key.permissions
    end

    test "create repository key for unknown repository is not allowed", c do
      body = %{
        name: "macbook",
        permissions: [%{domain: "repository", resource: "SOME_UNKNOWN_REPO"}]
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", key_for(c.eric))
      |> post("api/keys", Jason.encode!(body))
      |> json_response(422)

      refute Repo.one(Key.get(c.eric, "macbook"))
    end
  end

  describe "DELETE /api/keys" do
    test "delete all keys", c do
      key_a = Key.build(c.eric, %{name: "key_a"}) |> Repo.insert!()
      key_b = Key.build(c.eric, %{name: "key_b"}) |> Repo.insert!()

      conn =
        build_conn()
        |> put_req_header("authorization", key_a.user_secret)
        |> delete("api/keys")

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert body["name"] == key_a.name
      assert body["revoked_at"]
      assert body["updated_at"]
      assert body["inserted_at"]
      refute body["secret"]
      assert body["authing_key"]
      refute Repo.one(Key.get(c.eric, "key_a"))
      refute Repo.one(Key.get(c.eric, "key_b"))

      assert Repo.one(Key.get_revoked(c.eric, "key_a"))
      assert Repo.one(Key.get_revoked(c.eric, "key_b"))

      assert [log_a, log_b] =
               AuditLog
               |> Repo.all()
               |> Enum.sort_by(fn %{params: %{"name" => name}} -> name end)

      assert log_a.user_id == c.eric.id
      assert log_a.action == "key.remove"
      key_a_name = key_a.name
      assert %{"name" => ^key_a_name} = log_a.params
      assert log_b.user_id == c.eric.id
      assert log_b.action == "key.remove"
      key_b_name = key_b.name
      assert %{"name" => ^key_b_name} = log_b.params

      conn =
        build_conn()
        |> put_req_header("authorization", key_a.user_secret)
        |> get("api/keys")

      assert conn.status == 401
      body = Jason.decode!(conn.resp_body)
      assert %{"message" => "API key revoked", "status" => 401} == body
    end
  end

  describe "GET /api/keys/:name" do
    test "get key", c do
      c.eric
      |> Key.build(%{name: "macbook"})
      |> Repo.insert!()

      conn =
        build_conn()
        |> put_req_header("authorization", key_for(c.eric))
        |> get("api/keys/macbook")

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert body["name"] == "macbook"
      assert body["secret"] == nil
      assert body["permissions"] == [%{"domain" => "api", "resource" => nil}]
      refute body["authing_key"]
    end
  end

  describe "DELETE /api/keys/:name" do
    test "delete key", c do
      Key.build(c.eric, %{name: "macbook"}) |> Repo.insert!()
      Key.build(c.eric, %{name: "computer"}) |> Repo.insert!()

      conn =
        build_conn()
        |> put_req_header("authorization", key_for(c.eric))
        |> delete("api/keys/computer")

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert body["name"] == "computer"
      assert body["revoked_at"]
      assert body["updated_at"]
      assert body["inserted_at"]
      refute body["secret"]
      refute body["authing_key"]
      assert Repo.one(Key.get(c.eric, "macbook"))
      refute Repo.one(Key.get(c.eric, "computer"))

      assert Repo.one(Key.get_revoked(c.eric, "computer"))

      log = Repo.one!(AuditLog)
      assert log.user_id == c.eric.id
      assert log.action == "key.remove"
      assert %{"name" => "computer"} = log.params
    end

    test "delete current key notifies client", c do
      key = Key.build(c.eric, %{name: "current"}) |> Repo.insert!()

      conn =
        build_conn()
        |> put_req_header("authorization", key.user_secret)
        |> delete("api/keys/current")

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert body["name"] == "current"
      assert body["revoked_at"]
      assert body["updated_at"]
      assert body["inserted_at"]
      refute body["secret"]
      assert body["authing_key"]
      refute Repo.one(Key.get(c.eric, "current"))

      assert Repo.one(Key.get_revoked(c.eric, "current"))

      log = Repo.one!(AuditLog)
      assert log.user_id == c.eric.id
      assert log.action == "key.remove"
      assert %{"name" => "current"} = log.params

      conn =
        build_conn()
        |> put_req_header("authorization", key.user_secret)
        |> get("api/keys")

      assert conn.status == 401
      body = Jason.decode!(conn.resp_body)
      assert %{"message" => "API key revoked", "status" => 401} == body
    end
  end
end
