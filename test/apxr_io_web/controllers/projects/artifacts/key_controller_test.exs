defmodule ApxrIoWeb.Projects.Artifacts.KeyControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  setup do
    user = insert(:user)
    team = insert(:team)

    project = insert(:project, team_id: team.id)

    rel =
      insert(
        :release,
        project: project,
        version: "0.0.1",
        meta: build(:release_metadata)
      )

    exp =
      insert(
        :experiment,
        release: rel
      )

    artifact =
      insert(
        :artifact,
        experiment: exp,
        project: project
      )

    %{
      team: team,
      user: user,
      project: project,
      experiment: exp,
      artifact: artifact
    }
  end

  defp mock_billing_settings(team) do
    Mox.stub(ApxrIo.Billing.Mock, :teams, fn token ->
      assert team.name == token

      %{
        "checkout_html" => "",
        "invoices" => []
      }
    end)
  end

  describe "POST /projects/:project/artifacts/:artifact/keys" do
    test "generate a new key", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")

      conn =
        build_conn()
        |> test_login(c.user)
        |> post(
          "/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys",
          %{key: %{name: "computer"}}
        )

      assert redirected_to(conn) ==
               "/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys"

      assert get_flash(conn, :info) =~ "Copy the secret"
    end
  end

  describe "DELETE /projects/:project/artifacts/:artifact/keys" do
    test "revoke key", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")
      key = insert(:key, artifact: c.artifact, name: "computer")

      mock_billing_settings(c.team)

      conn =
        build_conn()
        |> test_login(c.user)
        |> delete("/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys/#{key.name}")

      assert redirected_to(conn) ==
               "/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys"

      assert get_flash(conn, :info) =~ "The key computer was revoked successfully"
    end

    test "revoking an already revoked key throws an error", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")

      key =
        insert(:key,
          team: c.team,
          name: "computer",
          revoked_at: ~N"2017-01-01 00:00:00"
        )

      mock_billing_settings(c.team)

      conn =
        build_conn()
        |> test_login(c.user)
        |> delete("/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys/#{key.name}")

      assert response(conn, 400) =~ "The key computer was not found"
    end
  end
end
