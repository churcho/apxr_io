defmodule ApxrIoWeb.API.AuthControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    owned_team = insert(:team)
    unowned_team = insert(:team)
    user = insert(:user)
    insert(:team_user, team: owned_team, user: user)

    user_full_key =
      insert(
        :key,
        user: user,
        permissions: [
          build(:key_permission, domain: "api"),
          build(:key_permission, domain: "repository", resource: owned_team.name)
        ]
      )

    team_full_key =
      insert(
        :key,
        team: owned_team,
        permissions: [
          build(:key_permission, domain: "api"),
          build(:key_permission, domain: "repository", resource: owned_team.name)
        ]
      )

    user_api_key = insert(:key, user: user, permissions: [build(:key_permission, domain: "api")])

    team_api_key =
      insert(:key, team: owned_team, permissions: [build(:key_permission, domain: "api")])

    user_repo_key =
      insert(
        :key,
        user: user,
        permissions: [build(:key_permission, domain: "repository", resource: owned_team.name)]
      )

    team_repo_key =
      insert(
        :key,
        team: owned_team,
        permissions: [build(:key_permission, domain: "repository", resource: owned_team.name)]
      )

    user_all_repos_key =
      insert(:key, user: user, permissions: [build(:key_permission, domain: "repositories")])

    unowned_user_repo_key =
      insert(
        :key,
        user: user,
        permissions: [build(:key_permission, domain: "repository", resource: unowned_team.name)]
      )

    project = insert(:project, team_id: owned_team.id)

    release = insert(:release, project: project, version: "0.0.1")

    experiment =
      insert(
        :experiment,
        release: release
      )

    artifact =
      insert(
        :artifact,
        experiment: experiment,
        project: project
      )

    {:ok,
     [
       owned_team: owned_team,
       unowned_team: unowned_team,
       user: user,
       user_full_key: user_full_key,
       user_api_key: user_api_key,
       user_repo_key: user_repo_key,
       user_all_repos_key: user_all_repos_key,
       unowned_user_repo_key: unowned_user_repo_key,
       team_full_key: team_full_key,
       team_api_key: team_api_key,
       team_repo_key: team_repo_key,
       artifact: artifact
     ]}
  end

  describe "GET /api/auth" do
    test "without key" do
      build_conn()
      |> get("api/auth", domain: "api")
      |> response(401)
    end

    test "with invalid key" do
      build_conn()
      |> put_req_header("authorization", "ABC")
      |> get("api/auth", domain: "api")
      |> response(401)
    end

    test "without domain returns 400", %{user_full_key: key} do
      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth")
      |> response(400)
    end

    test "with revoked key", %{user: user} do
      key =
        insert(:key,
          user: user,
          permissions: [build(:key_permission, domain: "api")],
          revoked_at: ~N[2018-01-01 00:00:00]
        )

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api")
      |> response(401)

      key =
        insert(:key,
          user: user,
          permissions: [build(:key_permission, domain: "api")],
          revoke_at: ~N[2018-01-01 00:00:00]
        )

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api")
      |> response(401)

      key =
        insert(:key,
          user: user,
          permissions: [build(:key_permission, domain: "api")],
          revoke_at: ~N[2030-01-01 00:00:00]
        )

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api")
      |> response(204)
    end

    test "authenticate full user key", %{
      user_full_key: key,
      owned_team: owned_team,
      unowned_team: unowned_team
    } do
      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: owned_team.name)
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: unowned_team.name)
      |> response(401)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: "BADREPO")
      |> response(401)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository")
      |> response(401)
    end

    test "authenticate full team key", %{
      team_full_key: key,
      owned_team: owned_team,
      unowned_team: unowned_team
    } do
      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: owned_team.name)
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: unowned_team.name)
      |> response(401)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: "BADREPO")
      |> response(401)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository")
      |> response(401)
    end

    test "authenticate user api key", %{user_api_key: key} do
      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "read")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "write")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: "myrepo")
      |> response(401)
    end

    test "authenticate team api key", %{team_api_key: key} do
      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "read")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "write")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: "myrepo")
      |> response(401)
    end

    test "authenticate user read api key", %{user: user} do
      permission = build(:key_permission, domain: "api", resource: "read")
      key = insert(:key, user: user, permissions: [permission])

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "read")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "write")
      |> response(401)
    end

    test "authenticate user write api key", %{user: user} do
      permission = build(:key_permission, domain: "api", resource: "write")
      key = insert(:key, user: user, permissions: [permission])

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "write")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "read")
      |> response(401)
    end

    test "authenticate team read api key", %{owned_team: owned_team} do
      permission = build(:key_permission, domain: "api", resource: "read")
      key = insert(:key, team: owned_team, permissions: [permission])

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "read")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "write")
      |> response(401)
    end

    test "authenticate team write api key", %{owned_team: owned_team} do
      permission = build(:key_permission, domain: "api", resource: "write")
      key = insert(:key, team: owned_team, permissions: [permission])

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "write")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api", resource: "read")
      |> response(401)
    end

    test "authenticate user repo key with all repositories", %{
      user_all_repos_key: key,
      owned_team: owned_team,
      unowned_team: unowned_team
    } do
      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "api")
      |> response(401)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repositories")
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: owned_team.name)
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: unowned_team.name)
      |> response(403)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: "BADREPO")
      |> response(403)
    end

    test "authenticate artifact key", %{artifact: artifact} do
      permission = build(:key_permission, domain: "artifact", resource: artifact.name)
      key = insert(:key, artifact: artifact, permissions: [permission])

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "artifact", resource: artifact.name)
      |> response(204)

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "artifact", resource: "not_my_artifact")
      |> response(401)
    end

    test "authenticate repository key against repository without access permissions", %{
      unowned_user_repo_key: key,
      unowned_team: unowned_team
    } do
      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: unowned_team.name)
      |> response(403)
    end

    test "authenticate user repository key without active billing", %{user: user} do
      team = insert(:team, billing_active: false)
      insert(:team_user, team: team, user: user)

      key =
        insert(
          :key,
          user: user,
          permissions: [build(:key_permission, domain: "repository", resource: team.name)]
        )

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: team.name)
      |> response(403)
    end

    test "authenticate team repository key without active billing" do
      team = insert(:team, billing_active: false)

      key =
        insert(
          :key,
          team: team,
          permissions: [build(:key_permission, domain: "repository", resource: team.name)]
        )

      build_conn()
      |> put_req_header("authorization", key.user_secret)
      |> get("api/auth", domain: "repository", resource: team.name)
      |> response(403)
    end
  end
end
