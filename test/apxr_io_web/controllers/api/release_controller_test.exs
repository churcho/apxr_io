defmodule ApxrIoWeb.API.ReleaseControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIo.Accounts.AuditLog
  alias ApxrIo.Repository.{Project, Release}

  setup do
    user = insert(:user)
    team = insert(:team)

    project =
      insert(:project,
        team: team,
        project_owners: [build(:project_owner, user: user)]
      )

    release = insert(:release, project: project, version: "0.0.1")

    %{
      user: user,
      team: team,
      project: project,
      release: release
    }
  end

  describe "POST /api/repos/:repository/projects/:name/releases" do
    test "new project authorizes", %{user: user, team: team} do
      meta = %{
        name: "aname",
        version: "1.0.0",
        description: "Domain-specific language."
      }

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(403)

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/projects/#{meta.name}/releases", create_tar(meta, []))
      |> json_response(403)
    end

    test "existing project authorizes", %{user: user, team: team} do
      project =
        insert(
          :project,
          team_id: team.id,
          project_owners: [build(:project_owner, user: user)]
        )

      meta = %{name: project.name, version: "1.0.0", description: "Domain-specific language."}

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/projects/#{meta.name}/releases", create_tar(meta, []))
      |> json_response(403)
    end

    test "create release and new project", %{team: team, user: user} do
      insert(:team_user, team: team, user: user, role: "write")

      meta = %{
        name: Fake.sequence(:project),
        version: "1.0.0",
        description: "Domain-specific language."
      }

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/projects/#{meta.name}/releases", create_tar(meta, []))
      |> json_response(201)

      project = ApxrIo.Repo.get_by!(Project, name: meta.name)
      project_owner = ApxrIo.Repo.one!(assoc(project, :owners))
      assert project_owner.id == user.id

      log = ApxrIo.Repo.one!(AuditLog)
      assert log.user_id == user.id
      assert log.team_id == team.id
      assert log.action == "release.publish"
      assert log.params["project"]["name"] == meta.name
      assert log.params["release"]["version"] == "1.0.0"
    end

    test "update project", %{user: user, project: project, team: team} do
      insert(:team_user, team: team, user: user)

      meta = %{name: project.name, version: "1.0.0", description: "awesomeness"}

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/projects/#{project.name}/releases", create_tar(meta, []))
      |> json_response(201)

      assert ApxrIo.Repo.get_by(Project, name: project.name).meta.description == "awesomeness"
    end

    test "update project fails when version is invalid",
         %{user: user, project: project, team: team} do
      insert(:team_user, team: team, user: user)

      meta = %{name: project.name, version: "1.0-dev", description: "not-so-awesome"}

      result = 
        build_conn()
        |> put_req_header("content-type", "application/octet-stream")
        |> put_req_header("authorization", key_for(user))
        |> post("api/repos/#{team.name}/projects/#{project.name}/releases", create_tar(meta, []))
        |> json_response(422)

      assert result["message"] =~ "Validation error"
      assert result["errors"] == %{"version" => "is invalid SemVer"}
    end

    test "create release checks if project name is correct", %{
      user: user,
      project: project,
      team: team
    } do
      insert(:team_user, team: team, user: user, role: "admin")

      meta = %{name: Fake.sequence(:project), version: "0.1.0", description: "description"}

      result =
        build_conn()
        |> put_req_header("content-type", "application/octet-stream")
        |> put_req_header("authorization", key_for(user))
        |> post("api/repos/#{team.name}/projects/#{project.name}/releases", create_tar(meta, []))
        |> json_response(422)
        
      assert result["errors"]["name"] == "metadata does not match project name"

      meta = %{name: project.name, version: "1.0.0", description: "description"}

      result =
        build_conn()
        |> put_req_header("content-type", "application/octet-stream")
        |> put_req_header("authorization", key_for(user))
        |> post(
          "api/repos/#{team.name}/projects/#{Fake.sequence(:project)}/releases",
          create_tar(meta, [])
        )
        |> json_response(422)

      assert result["errors"]["name"] == "has already been taken"
    end
  end

  describe "POST /api/repos/:repository/publish" do
    test "create release and new project", %{user: user, team: team} do
      insert(:team_user, team: team, user: user, role: "admin")

      meta = %{
        name: Fake.sequence(:project),
        version: "1.0.0",
        description: "Domain-specific language."
      }

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(201)

      project = ApxrIo.Repo.get_by!(Project, name: meta.name)
      project_owner = ApxrIo.Repo.one!(assoc(project, :owners))
      assert project_owner.id == user.id

      log = ApxrIo.Repo.one!(AuditLog)
      assert log.user_id == user.id
      assert log.team_id == team.id
      assert log.action == "release.publish"
      assert log.params["project"]["name"] == meta.name
      assert log.params["release"]["version"] == "1.0.0"
    end

    test "create release authorizes existing project", %{team: team, project: project} do
      other_user = insert(:user)

      meta = %{name: project.name, version: "0.1.0", description: "description"}

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(other_user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(403)

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", "WRONG")
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(401)
    end

    test "update project authorizes", %{team: team, project: project} do
      meta = %{name: project.name, version: "1.0.0", description: "Domain-specific language."}

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", "WRONG")
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(401)
    end

    test "create project validates", %{user: user, team: team} do
      insert(:team_user, team: team, user: user, role: "admin")

      meta = %{
        name: Fake.sequence(:project),
        version: "1.0.0",
        links: "invalid",
        description: "description"
      }

      result =
        build_conn()
        |> put_req_header("content-type", "application/octet-stream")
        |> put_req_header("authorization", key_for(user))
        |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
        |> json_response(422)

      assert result["errors"]["meta"]["links"] == "expected type map(string)"
    end

    test "create project casts proplist metadata", %{user: user, team: team} do
      meta = %{
        name: Fake.sequence(:project),
        version: "1.0.0",
        links: %{"link" => "http://localhost"},
        extra: %{"key" => "value"},
        description: "description"
      }

      insert(:team_user, team: team, user: user, role: "admin")

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(201)
      
      project = ApxrIo.Repo.get_by!(Project, name: meta.name)
      assert project.meta.links == %{"link" => "http://localhost"}
      assert project.meta.extra == %{"key" => "value"}
    end

    test "create releases", %{user: user, team: team} do
      insert(:team_user, team: team, user: user, role: "admin")

      meta = %{
        name: Fake.sequence(:project),
        app: "other",
        version: "0.0.1",
        description: "description"
      }

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(201)

      meta = %{name: meta.name, version: "0.0.2", description: "description"}

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/projects/#{meta.name}/releases", create_tar(meta, []))
      |> json_response(201)

      project = ApxrIo.Repo.get_by!(Project, name: meta.name)
      project_id = project.id

      assert [
               %Release{project_id: ^project_id, version: %Version{major: 0, minor: 0, patch: 2}},
               %Release{project_id: ^project_id, version: %Version{major: 0, minor: 0, patch: 1}}
             ] = Release.all(project) |> ApxrIo.Repo.all() |> Release.sort()

      ApxrIo.Repo.get_by!(assoc(project, :releases), version: "0.0.1")
    end

    test "create release also creates project", %{user: user, team: team} do
      insert(:team_user, team: team, user: user, role: "admin")

      meta = %{name: Fake.sequence(:project), version: "1.0.0", description: "Web framework"}

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(201)

      ApxrIo.Repo.get_by!(Project, name: meta.name)
    end

    test "update release", %{user: user, team: team} do
      insert(:team_user, team: team, user: user, role: "admin")

      meta = %{name: Fake.sequence(:project), version: "0.0.1", description: "description"}

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(201)

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/projects/#{meta.name}/releases", create_tar(meta, []))
      |> json_response(200)

      project = ApxrIo.Repo.get_by!(Project, name: meta.name)
      ApxrIo.Repo.get_by!(assoc(project, :releases), version: "0.0.1")

      assert [%AuditLog{action: "release.publish"}, %AuditLog{action: "release.publish"}] =
               ApxrIo.Repo.all(AuditLog)
    end

    test "new project requries write permission", %{user: user, team: team} do
      insert(:team_user, team: team, user: user, role: "read")

      meta = %{
        name: Fake.sequence(:project),
        version: "1.0.0",
        description: "Domain-specific language."
      }

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(403)

      refute ApxrIo.Repo.get_by(Project, name: meta.name)
    end

    test "team needs to have active billing", %{user: user} do
      team = insert(:team, billing_active: false)

      insert(:team_user, team: team, user: user, role: "write")

      meta = %{
        name: Fake.sequence(:project),
        version: "1.0.0",
        description: "Domain-specific language."
      }

      build_conn()
      |> put_req_header("content-type", "application/octet-stream")
      |> put_req_header("authorization", key_for(user))
      |> post("api/repos/#{team.name}/publish", create_tar(meta, []))
      |> json_response(403)

      refute ApxrIo.Repo.get_by(Project, name: meta.name)
    end
  end

  describe "DELETE /api/repos/:repository/projects/:name/releases/:version" do
    test "authorizes", %{user: user, team: team} do
      project =
        insert(
          :project,
          team_id: team.id,
          project_owners: [build(:project_owner, user: user)]
        )

      insert(:release, project: project, version: "0.0.1")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/releases/0.0.1")
      |> response(403)

      assert ApxrIo.Repo.get_by(Project, name: project.name)
      assert ApxrIo.Repo.get_by(assoc(project, :releases), version: "0.0.1")
    end

    test "team needs to have active billing", %{user: user} do
      team = insert(:team, billing_active: false)
      insert(:team_user, team: team, user: user, role: "write")

      project =
        insert(
          :project,
          team_id: team.id,
          project_owners: [build(:project_owner, user: user)]
        )

      insert(:release, project: project, version: "0.0.1")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/releases/0.0.1")
      |> response(403)

      assert ApxrIo.Repo.get_by(Project, name: project.name)
      assert ApxrIo.Repo.get_by(assoc(project, :releases), version: "0.0.1")
    end

    test "delete release", %{user: user, team: team} do
      project =
        insert(
          :project,
          team_id: team.id,
          project_owners: [build(:project_owner, user: user)]
        )

      insert(:release, project: project, version: "0.0.1")
      insert(:team_user, team: team, user: user)

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/releases/0.0.1")
      |> response(204)

      refute ApxrIo.Repo.get_by(Project, name: project.name)
      refute ApxrIo.Repo.get_by(assoc(project, :releases), version: "0.0.1")
    end
  end

  describe "GET api/repos/:repository/projects/:name/releases/:version" do
    test "get release", %{user: user, project: project, release: release, team: team} do
      insert(:team_user, team: team, user: user, role: "read")

      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}")
        |> json_response(200)

      assert result["version"] == "#{release.version}"
    end

    test "get unknown release", %{user: user, project: project, team: team} do
      insert(:team_user, team: team, user: user, role: "admin")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/#{team.name}/projects/#{project.name}/releases/1.2.23423")
      |> json_response(404)

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/#{team.name}/projects/unknown/releases/1.2.3")
      |> json_response(404)
    end
  end

  describe "GET /api/repos/:repository/projects/:name/releases/:version" do
    test "get release authorizes", %{user: user, team: team} do
      project = insert(:project, team_id: team.id)

      insert(:release, project: project, version: "0.0.1")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/#{team.name}/projects/#{project.name}/releases/0.0.1")
      |> json_response(403)
    end

    test "get release returns 403 for non-existant repository", %{user: user, team: team} do
      project = insert(:project, team: team)

      insert(:release, project: project, version: "0.0.1")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/NONEXISTANT_REPOSITORY/projects/#{project.name}/releases/0.0.1")
      |> json_response(403)
    end

    test "get release", %{user: user, team: team} do
      project = insert(:project, team_id: team.id)

      insert(:release, project: project, version: "0.0.1")
      insert(:team_user, team: team, user: user)

      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects/#{project.name}/releases/0.0.1")
        |> json_response(200)

      assert result["version"] == "0.0.1"
    end
  end
end
