defmodule ApxrIoWeb.API.UserControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  alias ApxrIo.Accounts.User

  defp publish_project(user, myrepo) do
    meta = %{name: "ecto", version: "1.0.0", description: "Domain-specific language."}
    body = create_tar(meta, [])

    build_conn()
    |> put_req_header("content-type", "application/octet-stream")
    |> put_req_header("authorization", key_for(user))
    |> post("api/repos/#{myrepo.name}/projects/ecto/releases", body)
  end

  describe "POST /api/users" do
    test "create user" do
      params = %{
        username: Fake.sequence(:username),
        email: Fake.sequence(:email)
      }

      conn = json_post(build_conn(), "api/users", params)
      assert json_response(conn, 201)

      user = ApxrIo.Repo.get_by!(User, username: params.username) |> ApxrIo.Repo.preload(:emails)
      assert List.first(user.emails).email == params.email
    end

    test "create user sends email and requires confirmation" do
      params = %{
        username: Fake.sequence(:username),
        email: Fake.sequence(:email)
      }

      conn = json_post(build_conn(), "api/users", params)

      assert conn.status == 201
      user = ApxrIo.Repo.get_by!(User, username: params.username) |> ApxrIo.Repo.preload(:emails)
      user_email = List.first(user.emails)

      assert_delivered_email(ApxrIo.Emails.verification(user, user_email))

      myrepo = insert(:team, name: "myrepo")
      insert(:team_user, team: myrepo, user: user, role: "admin")

      conn = publish_project(user, myrepo)
      assert json_response(conn, 403)["message"] == "email not verified"

      conn =
        get(
          build_conn(),
          "email/verify?username=#{params.username}&email=#{URI.encode_www_form(user_email.email)}&key=#{
            user_email.verification_key
          }"
        )

      assert redirected_to(conn) == "/login"
      assert get_flash(conn, :info) =~ "verified"

      conn = publish_project(user, myrepo)
      assert conn.status == 201
    end

    test "create user validates" do
      params = %{username: Fake.sequence(:username)}
      conn = json_post(build_conn(), "api/users", params)

      result = json_response(conn, 422)
      assert result["message"] == "Validation error(s)"
      assert result["errors"]["emails"] == "can't be blank"
      refute ApxrIo.Repo.get_by(User, username: params.username)
    end
  end

  describe "GET /api/users/me" do
    test "get current user" do
      user = insert(:user)
      team = insert(:team, users: [user])
      project1 = insert(:project, team: team, project_owners: [build(:project_owner, user: user)])

      project2 =
        insert(
          :project,
          team_id: team.id,
          project_owners: [build(:project_owner, user: user)]
        )

      insert(:team_user, team: team, user: user)

      body =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/users/me")
        |> json_response(200)

      assert body["username"] == user.username
      assert body["email"] == hd(user.emails).email
      refute body["emails"]
      assert hd(body["teams"])["name"] == team.name
      assert hd(body["teams"])["role"] == "read"

      assert [json1, json2] = body["projects"]
      assert json1["name"] =~ project1.name || project2.name
      assert json2["repository"] =~ team.name
    end

    test "return 401 if not authenticated" do
      build_conn()
      |> get("api/users/me")
      |> json_response(401)
    end

    test "return 404 for team keys" do
      team = insert(:team)

      build_conn()
      |> put_req_header("authorization", key_for(team))
      |> get("api/users/me")
      |> json_response(404)
    end
  end
end
