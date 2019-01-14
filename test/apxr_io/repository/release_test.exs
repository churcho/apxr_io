defmodule ApxrIo.Repository.ReleaseTest do
  use ApxrIo.DataCase, async: true

  alias ApxrIo.Repository.Release

  setup do
    t = insert(:team)

    p1 = insert(:project, team: t)
    p2 = insert(:project, team: t)
    p3 = insert(:project, team: t)

    projects = [%{p1 | team: t}, %{p2 | team: t}, %{p3 | team: t}]

    %{projects: projects}
  end

  test "create release and get", %{projects: [project, _, _]} do
    project_id = project.id

    assert %Release{project_id: ^project_id, version: %Version{major: 0, minor: 0, patch: 1}} =
             Release.build(project, rel_meta(%{version: "0.0.1", build_tool: "elixir"}), "")
             |> ApxrIo.Repo.insert!()

    assert %Release{project_id: ^project_id, version: %Version{major: 0, minor: 0, patch: 1}} =
             ApxrIo.Repo.get_by!(assoc(project, :releases), version: "0.0.1")

    Release.build(project, rel_meta(%{version: "0.0.2", build_tool: "elixir"}), "")
    |> ApxrIo.Repo.insert!()

    assert [
             %Release{version: %Version{major: 0, minor: 0, patch: 2}},
             %Release{version: %Version{major: 0, minor: 0, patch: 1}}
           ] = Release.all(project) |> ApxrIo.Repo.all() |> Release.sort()
  end

  test "release version is unique", %{projects: [project1, project2, _]} do
    insert(:release, project: project1, version: "0.0.1")

    insert(:release, project: project2, version: "0.0.1")

    assert {:error, %{errors: [version: {"has already been published", _}]}} =
             Release.build(project1, rel_meta(%{version: "0.0.1", build_tool: "elixir"}), "")
             |> ApxrIo.Repo.insert()
  end

  test "update release", %{projects: [_, project2, project3]} do
    insert(:release, project: project3, version: "0.0.1")

    release = insert(:release, project: project2, version: "0.0.1")

    Release.update(%{release | project: project2}, %{}, "") |> ApxrIo.Repo.update!()

    assoc(project2, :releases)
    |> ApxrIo.Repo.get_by!(version: "0.0.1")
  end

  test "update release fails with invalid version", %{projects: [_, project2, project3]} do
    insert(:release, project: project3, version: "0.0.1")

    release = insert(:release, project: project2, version: "0.0.1")

    params = params(%{version: "1.0"})

    changeset = Release.update(%{release | project: project2}, params, "")
    assert [version: {"is invalid SemVer", _}] = changeset.errors
  end

  test "delete release", %{projects: [_, project2, _]} do
    release =
      Release.build(project2, rel_meta(%{version: "0.0.1", build_tool: "elixir"}), "")
      |> ApxrIo.Repo.insert!()

    Release.delete(release) |> ApxrIo.Repo.delete!()
    refute ApxrIo.Repo.get_by(assoc(project2, :releases), version: "0.0.1")
  end
end
