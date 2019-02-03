defmodule ApxrIoWeb.ProjectControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    user1 = insert(:user)
    user2 = insert(:user)

    team1 = insert(:team)
    team2 = insert(:team)

    project1 = insert(:project, team_id: team1.id)
    project2 = insert(:project, team_id: team1.id)
    project3 = insert(:project, team_id: team2.id)
    project4 = insert(:project, team_id: team2.id)

    insert(
      :release,
      project: project1,
      version: "0.0.1",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project1,
      version: "0.0.2",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project1,
      version: "0.0.3-dev",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project2,
      version: "1.0.0",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project3,
      version: "0.0.1",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project4,
      version: "0.0.1",
      meta: build(:release_metadata)
    )

    insert(:team_user, user: user1, team: team1)

    %{
      project1: project1,
      project2: project2,
      project3: project3,
      project4: project4,
      team1: team1,
      team2: team2,
      user1: user1,
      user2: user2
    }
  end

  describe "GET /projects" do
    test "list projects", %{
      user1: user1
    } do
      conn =
        build_conn()
        |> test_login(user1)
        |> get("/projects")

      response(conn, 200)
    end
  end

  describe "GET /projects/:name" do
    test "show project", %{user1: user1, project1: project1} do
      build_conn()
      |> test_login(user1)
      |> get("/projects/#{project1.name}")
      |> response(200)
    end
  end

  describe "GET /projects/:name/:version" do
    test "show project version", %{user1: user1, project1: project1} do
      build_conn()
      |> test_login(user1)
      |> get("/projects/#{project1.name}/0.0.1")
      |> response(200)
    end

    test "dont show private project", %{
      user1: user1,
      project3: project3
    } do
      build_conn()
      |> test_login(user1)
      |> get("/projects/#{project3.name}")
      |> response(404)
    end
  end
end
