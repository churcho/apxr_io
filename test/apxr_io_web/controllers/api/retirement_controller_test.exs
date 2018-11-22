defmodule ApxrIoWeb.API.RetirementControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    user = insert(:user)
    team = insert(:team)

    project =
      insert(:project,
        team: team,
        project_owners: [build(:project_owner, user: user)]
      )

    team_project =
      insert(
        :project,
        team_id: team.id,
        project_owners: [build(:project_owner, user: user)]
      )

    insert(:release, project: project, version: "1.0.0")

    insert(
      :release,
      project: project,
      version: "2.0.0",
      retirement: %ApxrIo.Repository.ReleaseRetirement{reason: "security"}
    )

    insert(:release, project: team_project, version: "1.0.0")

    insert(
      :release,
      project: team_project,
      version: "2.0.0",
      retirement: %ApxrIo.Repository.ReleaseRetirement{reason: "security"}
    )

    %{
      user: user,
      project: project,
      team: team,
      team_project: team_project
    }
  end

  describe "POST /api/repos/:repository/projects/:name/releases/:version/retire" do
    test "returns 403 if you are not authorized", %{
      user: user,
      team: team,
      team_project: project
    } do
      params = %{"reason" => "security", "message" => "See CVE-NNNN"}

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/1.0.0/retire",
        params
      )
      |> response(403)

      release = ApxrIo.Repository.Releases.get(project, "1.0.0")
      refute release.retirement
    end

    test "returns 403 for unknown repository", %{user: user, team_project: project} do
      params = %{"reason" => "security", "message" => "See CVE-NNNN"}

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> post(
        "api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/releases/1.0.0/retire",
        params
      )
      |> response(403)

      release = ApxrIo.Repository.Releases.get(project, "1.0.0")
      refute release.retirement
    end

    test "returns 403 for missing project if you are not authorized", %{
      user: user,
      team: team,
      team_project: project
    } do
      params = %{"reason" => "security", "message" => "See CVE-NNNN"}

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> post(
        "api/repos/#{team.name}/projects/UNKNOWN_PROJECT/releases/1.0.0/retire",
        params
      )
      |> response(403)

      release = ApxrIo.Repository.Releases.get(project, "1.0.0")
      refute release.retirement
    end

    test "returns 404 for missing project if you are authorized", %{
      user: user,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user, role: "write")

      params = %{"reason" => "security", "message" => "See CVE-NNNN"}

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> post(
        "api/repos/#{team.name}/projects/UNKNOWN_PROJECT/releases/1.0.0/retire",
        params
      )
      |> response(404)

      release = ApxrIo.Repository.Releases.get(project, "1.0.0")
      refute release.retirement
    end

    test "retire release", %{
      user: user,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user)

      params = %{"reason" => "security", "message" => "See CVE-NNNN"}

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/1.0.0/retire",
        params
      )
      |> response(204)

      release = ApxrIo.Repository.Releases.get(project, "1.0.0")
      assert release.retirement
      assert release.retirement.reason == "security"
      assert release.retirement.message == "See CVE-NNNN"
    end

    test "retire release using write permission and without project owner", %{
      team: team,
      team_project: project
    } do
      user = insert(:user)
      insert(:team_user, team: team, user: user, role: "write")

      params = %{"reason" => "security", "message" => "See CVE-NNNN"}

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/1.0.0/retire",
        params
      )
      |> response(204)

      release = ApxrIo.Repository.Releases.get(project, "1.0.0")
      assert release.retirement
      assert release.retirement.reason == "security"
      assert release.retirement.message == "See CVE-NNNN"
    end
  end

  describe "DELETE /api/repos/:repository/projects/:name/releases/:version/retire" do
    test "unretire release", %{team: team, user: user, project: project} do
      insert(:team_user, team: team, user: user, role: "admin")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/releases/2.0.0/retire")
      |> response(204)

      release = ApxrIo.Repository.Releases.get(project, "2.0.0")
      refute release.retirement
    end

    test "returns 403 if you are not authorized", %{
      user: user,
      team: team,
      team_project: project
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/releases/2.0.0/retire")
      |> response(403)

      release = ApxrIo.Repository.Releases.get(project, "2.0.0")
      assert release.retirement
    end

    test "returns 403 for unknown repository", %{user: user, team_project: project} do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/releases/2.0.0/retire")
      |> response(403)

      release = ApxrIo.Repository.Releases.get(project, "2.0.0")
      assert release.retirement
    end

    test "returns 403 for missing project if you are not authorized", %{
      user: user,
      team: team,
      team_project: project
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/releases/2.0.0/retire")
      |> response(403)

      release = ApxrIo.Repository.Releases.get(project, "2.0.0")
      assert release.retirement
    end

    test "returns 404 for missing project if you are authorized", %{
      user: user,
      team: team,
      team_project: project
    } do
      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/releases/2.0.0/retire")
      |> response(404)

      release = ApxrIo.Repository.Releases.get(project, "2.0.0")
      assert release.retirement
    end

    test "unretire release using write permission and without project owner", %{
      team: team,
      team_project: project
    } do
      user = insert(:user)
      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/releases/2.0.0/retire")
      |> response(204)

      release = ApxrIo.Repository.Releases.get(project, "2.0.0")
      refute release.retirement
    end
  end
end
