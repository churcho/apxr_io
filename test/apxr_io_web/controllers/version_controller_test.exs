defmodule ApxrIoWeb.VersionControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    user1 = insert(:user)
    team1 = insert(:team)
    project1 = insert(:project, team_id: team1.id)

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

    insert(:team_user, user: user1, team: team1)

    %{
      project1: project1,
      team1: team1,
      user1: user1
    }
  end

  describe "GET /projects/:project_name/versions" do
    test "list project versions", %{
      user1: user1,
      project1: project1
    } do
      conn =
        build_conn()
        |> test_login(user1)
        |> get("/projects/#{project1.name}/versions")

      result = response(conn, 200)
      assert result =~ ~r/0.0.1/
      assert result =~ ~r/0.0.2/
      assert result =~ ~r/0.0.3-dev/
      assert result =~ project1.name
    end
  end
end
