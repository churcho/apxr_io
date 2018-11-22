defmodule ApxrIoWeb.API.RepositoryControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    user = insert(:user)
    team1 = insert(:team)
    team2 = insert(:team)
    team3 = insert(:team)
    insert(:team_user, user: user, team: team2)
    insert(:team_user, user: user, team: team3)
    %{user: user, team1: team1, team2: team2}
  end

  describe "GET /api/repos" do
    test "not authorized" do
      conn = get(build_conn(), "api/repos")
      json_response(conn, 401)
    end

    test "authorized", %{user: user} do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos")
        |> json_response(200)

      assert length(result) == 2
    end
  end

  describe "GET /api/repos/:repository" do
    test "not authorized", %{team1: team1} do
      conn = get(build_conn(), "api/repos/#{team1.name}")
      json_response(conn, 401)
    end

    test "authorized", %{user: user, team2: team2} do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team2.name}")
        |> json_response(200)

      assert result["name"] == team2.name
    end
  end
end
