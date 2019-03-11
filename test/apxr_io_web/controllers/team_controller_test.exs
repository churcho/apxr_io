defmodule ApxrIoWeb.TeamControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  alias ApxrIo.Accounts.Users

  defp add_email(user, email) do
    {:ok, user} = Users.add_email(user, %{email: email}, audit: audit_data(user))
    user
  end

  setup do
    %{
      user: create_user("eric", "eric@mail.com"),
      team: insert(:team)
    }
  end

  test "team members", %{user: user, team: team} do
    insert(:team_user, team: team, user: user)

    conn =
      build_conn()
      |> test_login(user)
      |> get("/teams/#{team.name}/members")

    assert response(conn, 200) =~ "Members"
  end

  test "team members authenticates", %{user: user, team: team} do
    build_conn()
    |> test_login(user)
    |> get("/teams/#{team.name}/members")
    |> response(404)
  end

  test "requires login" do
    conn = get(build_conn(), "/teams")
    assert redirected_to(conn) == "/?return=%2Fteams"
  end

  test "add member to team", %{user: user, team: team} do
    insert(:team_user, team: team, user: user, role: "admin")
    new_user = insert(:user)
    add_email(new_user, "new@mail.com")
    params = %{"username" => new_user.username, role: "write"}

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}", %{
        "action" => "add_member",
        "team_user" => params
      })

    assert redirected_to(conn) == "/teams/#{team.name}/members"
    assert repo_user = Repo.get_by(assoc(team, :team_users), user_id: new_user.id)
    assert repo_user.role == "write"

    assert_delivered_email(ApxrIo.Emails.team_invite(team, new_user))
  end

  test "remove member from team", %{user: user, team: team} do
    insert(:team_user, team: team, user: user, role: "admin")
    new_user = insert(:user)
    insert(:team_user, team: team, user: new_user)
    params = %{"username" => new_user.username}

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}", %{
        "action" => "remove_member",
        "team_user" => params
      })

    assert redirected_to(conn) == "/teams/#{team.name}/members"
    refute Repo.get_by(assoc(team, :team_users), user_id: new_user.id)
  end

  test "change role of member in team", %{user: user, team: team} do
    insert(:team_user, team: team, user: user, role: "admin")
    new_user = insert(:user)
    insert(:team_user, team: team, user: new_user, role: "write")
    params = %{"username" => new_user.username, "role" => "read"}

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}", %{
        "action" => "change_role",
        "team_user" => params
      })

    assert redirected_to(conn) == "/teams/#{team.name}/members"
    assert repo_user = Repo.get_by(assoc(team, :team_users), user_id: new_user.id)
    assert repo_user.role == "read"
  end

  test "create team", %{user: user} do
    params = %{
      "team" => %{"name" => "createrepo"},
      "person" => %{"country" => "SE"},
      "email" => "eric@mail.com"
    }

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams", params)

    response(conn, 302)
    assert get_resp_header(conn, "location") == ["/teams"]

    assert get_flash(conn, :info) == "Team created."
  end

  test "create team validates name", %{user: user} do
    insert(:team, name: "createrepovalidates")

    params = %{
      "team" => %{"name" => "createrepovalidates"},
      "person" => %{"country" => "SE"},
      "email" => "eric@mail.com"
    }

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams", params)

    assert response(conn, 400) =~ "Oops, something went wrong"
    assert response(conn, 400) =~ "has already been taken"
  end
end
