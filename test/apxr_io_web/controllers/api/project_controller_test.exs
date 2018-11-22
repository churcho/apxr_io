defmodule ApxrIoWeb.API.ProjectControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    user = insert(:user)
    unauthorized_user = insert(:user)
    team = insert(:team)
    other_team = insert(:team)

    project1 =
      insert(
        :project,
        team: team,
        name: "ApxrIoWeb.API.ProjectControllerTest",
        inserted_at: ~N[2030-01-01 00:00:00]
      )

    project2 = insert(:project, team: team, updated_at: ~N[2030-01-01 00:00:00])
    project3 = insert(:project, team: team, updated_at: ~N[2030-01-01 00:00:00])
    project4 = insert(:project, team: team)
    insert(:project, team: other_team)

    insert(:release, project: project1, version: "0.0.1")
    insert(:release, project: project3, version: "0.0.1")

    insert(
      :release,
      project: project4,
      version: "0.0.1",
      retirement: %{reason: "other", message: "not backward compatible"}
    )

    insert(:release, project: project4, version: "1.0.0")

    insert(:team_user, team: team, user: user)

    %{
      project1: project1,
      project2: project2,
      project3: project3,
      project4: project4,
      team: team,
      user: user,
      unauthorized_user: unauthorized_user
    }
  end

  describe "GET /api/repos/:repo/projects" do
    test "show projects in team", %{
      user: user,
      team: team,
      project3: project3
    } do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects")
        |> json_response(200)

      assert length(result) == 4
      assert project3.name in Enum.map(result, & &1["name"])
    end

    test "show projects in team authorizes", %{
      team: team,
      unauthorized_user: unauthorized_user
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects")
      |> json_response(401)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> get("api/repos/#{team.name}/projects")
      |> json_response(403)
    end
  end

  describe "GET /api/repos/:repo/projects/:name" do
    test "get project for unauthenticated team", %{
      team: team,
      project3: project3
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects/#{project3.name}")
      |> json_response(401)
    end

    test "get project returns 403 for unknown team", %{project1: project1} do
      build_conn()
      |> get("api/repos/UNKNOWN_REPOSITORY/projects/#{project1.name}")
      |> json_response(401)
    end

    test "get project returns 403 for unknown project if you are not authorized", %{
      team: team
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT")
      |> json_response(401)
    end

    test "get project returns 404 for unknown project if you are authorized", %{
      user: user,
      team: team
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT")
      |> json_response(404)
    end

    test "get project for authenticated team", %{
      user: user,
      team: team,
      project3: project3
    } do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects/#{project3.name}")
        |> json_response(200)

      assert result["name"] == project3.name
      assert result["repository"] == team.name
    end

    test "get project with retired versions", %{team: team, project4: project4, user: user} do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects/#{project4.name}")
        |> json_response(200)

      assert result["retirements"] == %{
               "0.0.1" => %{"message" => "not backward compatible", "reason" => "other"}
             }
    end
  end
end
