defmodule ApxrIoWeb.API.OwnerControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  alias ApxrIo.Accounts.User

  setup do
    user1 = insert(:user)
    user2 = insert(:user)
    team = insert(:team)
    some_other_team = insert(:team)

    project =
      insert(:project,
        team: some_other_team,
        project_owners: [build(:project_owner, user: user1)]
      )

    team_project =
      insert(
        :project,
        team: team,
        project_owners: [build(:project_owner, user: user1)]
      )

    %{
      user1: user1,
      user2: user2,
      team: team,
      project: project,
      team_project: team_project
    }
  end

  describe "GET /repos/:team/projects/:name/owners" do
    test "returns 403 if you are not authorized", %{
      user1: user1,
      team: team,
      team_project: project
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/#{team.name}/projects/#{project.name}/owners")
      |> json_response(403)
    end

    test "returns 403 for unknown team", %{
      user1: user1,
      team: team,
      team_project: project
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/owners")
      |> json_response(403)

      build_conn()
      |> put_req_header("authorization", key_for(team))
      |> get("api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/owners")
      |> json_response(403)
    end

    test "returns 403 for missing project if you are not authorized", %{
      user1: user1,
      team: team
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners")
      |> json_response(403)

      other_team = insert(:team)

      build_conn()
      |> put_req_header("authorization", key_for(other_team))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners")
      |> json_response(403)
    end

    test "returns 404 for missing project if you are authorized", %{
      user1: user1,
      team: team
    } do
      insert(:team_user, team: team, user: user1)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners")
      |> json_response(404)

      build_conn()
      |> put_req_header("authorization", key_for(team))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners")
      |> json_response(404)
    end

    test "get all project owners", %{
      user1: user1,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user1)

      result =
        build_conn()
        |> put_req_header("authorization", key_for(user1))
        |> get("api/repos/#{team.name}/projects/#{project.name}/owners")
        |> json_response(200)

      assert List.first(result)["username"] == user1.username
    end

    test "get all project owners for team key", %{
      user1: user1,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user1)

      result =
        build_conn()
        |> put_req_header("authorization", key_for(team))
        |> get("api/repos/#{team.name}/projects/#{project.name}/owners")
        |> json_response(200)

      assert List.first(result)["username"] == user1.username
    end
  end

  describe "GET /repos/:team/projects/:name/owners/:email" do
    test "returns 403 if you are not authorized", %{
      user1: user1,
      team: team,
      team_project: project
    } do
      email = User.email(user1, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(403)
    end

    test "returns 403 for unknown team", %{user1: user1, team_project: project} do
      email = User.email(user1, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/owners/#{email}")
      |> response(403)
    end

    test "returns 403 for missing project if you are not authorized", %{
      user1: user1,
      team: team
    } do
      email = User.email(user1, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners/#{email}")
      |> response(403)
    end

    test "returns 404 for missing project if you are authorized", %{
      user1: user1,
      team: team
    } do
      insert(:team_user, team: team, user: user1)

      email = User.email(user1, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners/#{email}")
      |> response(404)
    end

    test "check if user is project owner", %{
      user1: user1,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user1)

      email = User.email(user1, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> get("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(200)
    end
  end

  describe "PUT /repos/:team/projects/:name/owners/:email" do
    test "returns 403 if you are not authorized", %{
      user1: user1,
      user2: user2,
      team: team,
      team_project: project
    } do
      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> put("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(403)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 1
    end

    test "returns 403 for unknown team", %{
      user1: user1,
      user2: user2,
      team_project: project
    } do
      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> put("api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/owners/#{email}")
      |> response(403)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 1
    end

    test "returns 403 for missing project if you are not authorized", %{
      user1: user1,
      user2: user2,
      team: team,
      team_project: project
    } do
      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> put("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners/#{email}")
      |> response(403)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 1
    end

    test "returns 403 if team does not have active billing", %{user1: user1, user2: user2} do
      team = insert(:team, billing_active: false)
      insert(:team_user, team: team, user: user1)
      insert(:team_user, team: team, user: user2)

      project =
        insert(
          :project,
          team_id: team.id,
          project_owners: [build(:project_owner, user: user1)]
        )

      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> put("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(403)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 1
    end

    test "returns 404 for missing project if you are authorized", %{
      user1: user1,
      user2: user2,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user1, role: "admin")
      insert(:team_user, team: team, user: user2)

      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> put("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners/#{email}")
      |> response(404)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 1
    end

    test "requries owner to be member of team", %{
      user1: user1,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user1)
      user3 = insert(:user)

      email = User.email(user3, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> put("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(422)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 1
    end

    test "add project owner", %{
      user1: user1,
      user2: user2,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user1)
      insert(:team_user, team: team, user: user2)

      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> put("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(204)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 2
    end

    test "add project owner using admin permission and without project owner", %{
      user2: user2,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user2, role: "admin")
      user3 = insert(:user)
      insert(:team_user, team: team, user: user3)

      email = User.email(user3, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user2))
      |> put("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(204)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 2
    end
  end

  describe "DELETE /repos/:team/projects/:name/owners/:email" do
    test "returns 403 if you are not authorized", %{
      user1: user1,
      user2: user2,
      team: team,
      team_project: project
    } do
      insert(:project_owner, project: project, user: user2)

      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(403)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 2
    end

    test "returns 403 for unknown team", %{
      user1: user1,
      user2: user2,
      team_project: project
    } do
      insert(:project_owner, project: project, user: user2)

      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> delete("api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/owners/#{email}")
      |> response(403)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 2
    end

    test "returns 403 for missing project if you are not authorized", %{
      user1: user1,
      user2: user2,
      team: team,
      team_project: project
    } do
      insert(:project_owner, project: project, user: user2)

      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> delete("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners/#{email}")
      |> response(403)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 2
    end

    test "returns 404 for missing project if you are authorized", %{
      user1: user1,
      user2: user2,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user1, role: "admin")
      insert(:project_owner, project: project, user: user2)

      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> delete("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/owners/#{email}")
      |> response(404)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 2
    end

    test "delete project owner", %{
      user1: user1,
      user2: user2,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user1)
      insert(:project_owner, project: project, user: user2)

      email = User.email(user2, :primary)

      build_conn()
      |> put_req_header("authorization", key_for(user1))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/owners/#{email}")
      |> response(204)

      assert ApxrIo.Repo.aggregate(assoc(project, :owners), :count, :id) == 1
    end
  end
end
