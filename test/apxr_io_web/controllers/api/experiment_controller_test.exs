defmodule ApxrIoWeb.API.ExperimentControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIo.Accounts.AuditLog
  alias ApxrIo.Learn.Experiment
  alias ApxrIo.Learn.Experiments

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
    release4 = insert(:release, project: project3, version: "0.0.1")

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

    experiment2 = build_experiment(release2.id)
    experiment3 = build_experiment(release3.id)
    invalid_experiment = build_experiment(release2.id)
    uexperiment = build_experiment(release.id)

    %{
      project: project,
      project2: project2,
      project3: project3,
      project4: project4,
      release: release,
      release2: release2,
      release3: release3,
      release4: release4,
      experiment: experiment,
      experiment2: experiment2,
      experiment3: experiment3,
      uexperiment: uexperiment,
      invalid_experiment: invalid_experiment,
      team: team,
      nbteam: nbteam,
      user: user,
      unauthorized_user: unauthorized_user
    }
  end

  describe "GET /api/repos/:repo/projects/:project/experiments/all" do
    test "show experiments in project", %{
      user: user,
      team: team,
      project: project
    } do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects/#{project.name}/experiments/all")
        |> json_response(200)

      assert length(result) == 1
    end

    test "show experiments in team authorizes", %{
      team: team,
      unauthorized_user: unauthorized_user,
      project: project
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects/#{project.name}/experiments/all")
      |> json_response(401)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> get("api/repos/#{team.name}/projects/#{project.name}/experiments/all")
      |> json_response(403)
    end
  end

  describe "GET /api/repos/:repo/projects/:project/releases/:version/experiments/:id" do
    test "get experiment unauthenticated", %{
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> get(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> json_response(401)
    end

    test "get project returns 404 for unknown team", %{
      user: user,
      project: project,
      release: release,
      experiment: experiment
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get(
        "api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> json_response(404)
    end

    test "get experiment returns 404 for unknown project if you are authorized", %{
      user: user,
      team: team,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get(
        "api/repos/#{team.name}/projects/UNKNOWN_PROJECT/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> json_response(404)
    end
  end

  describe "POST /api/repos/:repo/:project/releases/:version/experiments" do
    test "create experiment authorizes", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      experiment3: experiment3,
      release3: release3
    } do
      experiment_count = Experiments.count(project)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release3.version}/experiments",
        %{"experiment" => experiment3}
      )
      |> json_response(403)

      assert experiment_count == Experiments.count(project)
    end

    test "experiment requires write permission", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      experiment3: experiment3,
      release3: release3
    } do
      insert(:team_user, team: team, user: unauthorized_user, role: "read")

      experiment_count = Experiments.count(project)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release3.version}/experiments",
        %{"experiment" => experiment3}
      )
      |> json_response(403)

      assert experiment_count == Experiments.count(project)
    end

    test "team needs to have active billing", %{
      nbteam: nbteam,
      project3: project3,
      release4: release4,
      experiment3: experiment3
    } do
      user = insert(:user)

      insert(:team_user, team: nbteam, user: user, role: "write")

      experiment_count = Experiments.count(project3)

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{nbteam.name}/projects/#{project3.name}/releases/#{release4.version}/experiments",
        %{"experiment" => experiment3}
      )
      |> json_response(403)

      assert experiment_count == Experiments.count(project3)
    end

    test "create experiment validates parameters", %{
      team: team,
      project: project,
      invalid_experiment: invalid_experiment,
      release2: release2
    } do
      invalid_experiment1 =
        put_in(invalid_experiment, [:meta, :exp_parameters, :runs], "wrong value")

      experiment_count = Experiments.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      conn =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> json_post(
          "api/repos/#{team.name}/projects/#{project.name}/releases/#{release2.version}/experiments",
          %{"experiment" => invalid_experiment1}
        )

      assert conn.status == 422
      result = json_response(conn, 422)
      assert result["message"] =~ "Validation error"
      assert result["errors"] == %{"meta" => %{"exp_parameters" => "runs invalid"}}

      assert experiment_count == Experiments.count(project)
    end

    test "create experiment", %{
      team: team,
      project: project,
      experiment2: experiment2,
      release2: release2
    } do
      Mox.stub(ApxrIo.Learn.Mock, :start, fn _proj, _v, experiment, _audit_data ->
        {:ok, %{experiment: experiment}}
      end)

      experiment_count = Experiments.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release2.version}/experiments",
        %{"experiment" => experiment2}
      )
      |> json_response(201)

      assert experiment_count + 1 == Experiments.count(project)

      log = ApxrIo.Repo.one!(AuditLog)
      assert log.user_id == user.id
      assert log.team_id == team.id
      assert log.action == "experiment.create"
      assert log.params["project"]["name"] == project.name
      assert log.params["release"]["version"] == "0.0.2"
    end
  end

  describe "POST /api/repos/:repo/projects/:project/releases/:version/experiments/:id" do
    test "update experiment authorizes", %{
      team: team,
      project: project,
      experiment: experiment,
      uexperiment: uexperiment,
      release: release
    } do
      token =
        ApxrIo.Token.generate_and_sign!(%{
          "project" => project.name,
          "version" => release.version,
          "experiment" => experiment.id,
          "iss" => "bad",
          "aud" => "bad"
        })

      build_conn()
      |> put_req_header("token", token)
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }",
        %{"data" => uexperiment}
      )
      |> json_response(401)
    end

    test "update experiment", %{
      team: team,
      project: project,
      experiment: experiment,
      uexperiment: uexperiment,
      release: release
    } do
      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      token =
        ApxrIo.Token.generate_and_sign!(%{
          "project" => project.name,
          "version" => release.version,
          "experiment" => experiment.id,
          "iss" => "apxr_run",
          "aud" => "apxr_io"
        })

      build_conn()
      |> put_req_header("token", token)
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }",
        %{"data" => uexperiment}
      )
      |> json_response(201)
    end
  end

  describe "POST /api/repos/:repo/projects/:project/releases/:version/experiments/:id/pause" do
    test "pause experiment authorizes", %{
      user: user,
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }/pause",
        %{}
      )
      |> response(403)
    end

    test "pause experiment", %{
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      Mox.stub(ApxrIo.Learn.Mock, :pause, fn _proj, _v, _eid, _audit_data ->
        :ok
      end)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }/pause",
        %{}
      )
      |> response(204)
    end
  end

  describe "POST /api/repos/:repo/projects/:project/releases/:version/experiments/:id/continue" do
    test "continue experiment authorizes", %{
      user: user,
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }/continue",
        %{}
      )
      |> response(403)
    end

    test "continue experiment", %{
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      Mox.stub(ApxrIo.Learn.Mock, :continue, fn _proj, _v, _eid, _audit_data ->
        :ok
      end)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }/continue",
        %{}
      )
      |> response(204)
    end
  end

  describe "POST /api/repos/:repo/projects/:project/releases/:version/experiments/:id/stop" do
    test "stop experiment authorizes", %{
      user: user,
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }/stop",
        %{}
      )
      |> response(403)
    end

    test "stop experiment", %{
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      Mox.stub(ApxrIo.Learn.Mock, :stop, fn _proj, _v, _eid, _audit_data ->
        :ok
      end)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }/stop",
        %{}
      )
      |> response(204)
    end
  end

  describe "DELETE /api/repos/:repo/projects/:project/releases/:version/experiments/:id" do
    test "authorizes", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> delete(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> response(403)

      assert ApxrIo.Repo.get_by!(Experiment, id: experiment.id)
    end

    test "delete experiment", %{
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      Mox.stub(ApxrIo.Learn.Mock, :delete, fn _proj, _v, _eid, _audit_data ->
        :ok
      end)

      experiment_count = Experiments.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "admin")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> response(204)

      refute ApxrIo.Repo.get_by(Experiment, id: experiment.id)
      assert experiment_count - 1 == Experiments.count(project)

      [log] = ApxrIo.Repo.all(AuditLog)
      assert log.user_id == user.id
      assert log.action == "experiment.delete"
      assert log.params["project"]["name"] == project.name
      assert log.params["release"]["version"] == "0.0.1"
    end
  end
end
