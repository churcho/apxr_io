defmodule ApxrIoWeb.API.ArtifactControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIo.Accounts.AuditLog
  alias ApxrIo.Serve.Artifact
  alias ApxrIo.Serve.Artifacts

  setup do
    user = insert(:user)
    unauthorized_user = insert(:user)

    team = insert(:team)
    nbteam = insert(:team, billing_active: false)
    other_team = insert(:team)

    project = insert(:project, team: team)
    project2 = insert(:project, team: team)
    project3 = insert(:project, team: nbteam)
    project4 = insert(:project, team: other_team)

    release = insert(:release, project: project, version: "0.0.1")
    release2 = insert(:release, project: project, version: "0.0.2")
    release3 = insert(:release, project: project, version: "0.0.3")

    insert(:release, project: project2, version: "0.0.1")

    insert(:release,
      project: project4,
      version: "0.0.1",
      retirement: %{reason: "other", message: "not backward compatible"}
    )

    insert(:release, project: project4, version: "1.0.0")

    insert(:team_user, team: team, user: user)

    experiment =
      insert(
        :experiment,
        release: release
      )

    experiment2 =
      insert(
        :experiment,
        release: release2
      )

    experiment3 =
      insert(
        :experiment,
        release: release3
      )

    artifact =
      insert(
        :artifact,
        experiment: experiment,
        project: project,
        name: "artifact_name",
        status: "offline"
      )

    artifact2 = build_artifact(experiment2.id, project.id)
    artifact3 = build_artifact(experiment3.id, project.id)
    uartifact = build_artifact(nil, nil)

    %{
      project: project,
      project2: project2,
      project3: project3,
      project4: project4,
      release: release,
      artifact: artifact,
      artifact2: artifact2,
      artifact3: artifact3,
      uartifact: uartifact,
      team: team,
      nbteam: nbteam,
      user: user,
      unauthorized_user: unauthorized_user
    }
  end

  describe "GET /api/repos/:repo/projects/:project/artifacts/all" do
    test "show artifacts in project", %{
      user: user,
      team: team,
      project: project
    } do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects/#{project.name}/artifacts/all")
        |> json_response(200)

      assert length(result) == 1
    end

    test "show artifacts in team authorizes", %{
      team: team,
      unauthorized_user: unauthorized_user,
      project: project
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects/#{project.name}/artifacts/all")
      |> json_response(401)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> get("api/repos/#{team.name}/projects/#{project.name}/artifacts/all")
      |> json_response(403)
    end
  end

  describe "GET /api/repos/:repo/projects/:project/artifacts/:name" do
    test "get artifact unauthenticated", %{
      team: team,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}")
      |> json_response(401)
    end

    test "get project returns 404 for unknown team", %{
      user: user,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/artifacts/#{artifact.name}")
      |> json_response(404)
    end

    test "get artifact returns 404 for unknown project if you are authorized", %{
      user: user,
      team: team,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/artifacts/#{artifact.name}")
      |> json_response(404)
    end
  end

  describe "POST /api/repos/:repo/:project/artifacts" do
    test "create artifact authorizes", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      artifact3: artifact3
    } do
      artifact_count = Artifacts.count(project)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> json_post("api/repos/#{team.name}/projects/#{project.name}/artifacts", %{
        "artifact" => artifact3
      })
      |> json_response(403)

      assert artifact_count == Artifacts.count(project)
    end

    test "artifact requries write permission", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      artifact3: artifact3
    } do
      insert(:team_user, team: team, user: unauthorized_user, role: "read")

      artifact_count = Artifacts.count(project)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> json_post("api/repos/#{team.name}/projects/#{project.name}/artifacts", %{
        "artifact" => artifact3
      })
      |> json_response(403)

      assert artifact_count == Artifacts.count(project)
    end

    test "team needs to have active billing", %{
      nbteam: nbteam,
      project3: project3,
      artifact3: artifact3
    } do
      user = insert(:user)

      insert(:team_user, team: nbteam, user: user, role: "write")

      artifact_count = Artifacts.count(project3)

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post("api/repos/#{nbteam.name}/projects/#{project3.name}/artifacts", %{
        "artifact" => artifact3
      })
      |> json_response(403)

      assert artifact_count == Artifacts.count(project3)
    end

    test "create artifact", %{
      team: team,
      project: project,
      artifact2: artifact2
    } do
      artifact_count = Artifacts.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post("api/repos/#{team.name}/projects/#{project.name}/artifacts", %{
        "artifact" => artifact2
      })
      |> json_response(201)

      assert artifact_count + 1 == Artifacts.count(project)

      log = ApxrIo.Repo.one!(AuditLog)
      assert log.user_id == user.id
      assert log.team_id == team.id
      assert log.action == "artifact.publish"
      assert log.params["project"]["name"] == project.name
    end
  end

  describe "POST /api/repos/:repo/projects/:project/artifacts/:name" do
    test "update artifact authorizes", %{
      user: user,
      team: team,
      project: project,
      artifact: artifact,
      uartifact: uartifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}",
        %{"data" => uartifact}
      )
      |> json_response(403)
    end

    test "update artifact", %{
      team: team,
      project: project,
      artifact: artifact,
      uartifact: uartifact
    } do
      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}",
        %{"data" => uartifact}
      )
      |> json_response(201)
    end
  end

  describe "POST /api/repos/:repo/projects/:project/artifacts/:name/unpublish" do
    test "unpublish artifact authorizes", %{
      user: user,
      team: team,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}/unpublish",
        %{}
      )
      |> json_response(403)
    end

    test "unpublish artifact", %{
      team: team,
      project: project,
      artifact: artifact
    } do
      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}/unpublish",
        %{}
      )
      |> json_response(201)
    end
  end

  describe "POST /api/repos/:repo/projects/:project/artifacts/:name/republish" do
    test "republish artifact authorizes", %{
      user: user,
      team: team,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}/republish",
        %{}
      )
      |> json_response(403)
    end

    test "republish artifact", %{
      team: team,
      project: project,
      artifact: artifact
    } do
      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}/republish",
        %{}
      )
      |> json_response(201)
    end
  end

  describe "DELETE /api/repos/:repo/projects/:project/artifacts/:name" do
    test "authorizes", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}")
      |> response(403)

      assert ApxrIo.Repo.get_by!(Artifact, id: artifact.id)
    end

    test "delete artifact", %{
      team: team,
      project: project,
      artifact: artifact
    } do
      artifact_count = Artifacts.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "admin")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}")
      |> response(204)

      refute ApxrIo.Repo.get_by(Artifact, id: artifact.id)
      assert artifact_count - 1 == Artifacts.count(project)

      [log] = ApxrIo.Repo.all(AuditLog)
      assert log.user_id == user.id
      assert log.action == "artifact.delete"
      assert log.params["project"]["name"] == project.name
    end
  end
end
