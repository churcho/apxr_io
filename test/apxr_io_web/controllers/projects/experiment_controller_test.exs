defmodule ApxrIoWeb.Projects.ExperimentControllerTest do
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

    rel =
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

    experiment =
      insert(
        :experiment,
        release: rel
      )

    insert(:team_user, user: user1, team: team1)

    %{
      project1: project1,
      project2: project2,
      project3: project3,
      project4: project4,
      release: rel,
      experiment: experiment,
      team1: team1,
      team2: team2,
      user1: user1,
      user2: user2
    }
  end

  describe "GET /projects/:name/experiments/all" do
    test "list experiments", %{user1: user1, project1: project1} do
      build_conn()
      |> test_login(user1)
      |> get("/projects/#{project1.name}/experiments/all")
      |> response(200)
    end

    test "dont list private experiments", %{user1: user1, project3: project3} do
      build_conn()
      |> test_login(user1)
      |> get("/projects/#{project3.name}/experiments/all")
      |> response(404)
    end
  end

  describe "GET /projects/:name/releases/:version/experiments/:id" do
    test "show experiment", %{
      user1: user1,
      project1: project1,
      release: release,
      experiment: experiment
    } do
      build_conn()
      |> test_login(user1)
      |> get(
        "/projects/#{project1.name}/releases/#{release.version}/experiments/#{experiment.id}"
      )
      |> response(200)
    end
  end
end
