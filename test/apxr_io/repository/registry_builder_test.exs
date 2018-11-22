defmodule ApxrIo.Team.RegistryBuilderTest do
  use ApxrIo.DataCase

  alias ApxrIo.Repository.{RegistryBuilder, Release}

  @checksum "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

  setup do
    team = insert(:team)

    projects =
      [p1, p2, p3] =
      insert_list(3, :project, team: team)
      |> ApxrIo.Repo.preload(:team)

    r1 = insert(:release, project: p1, version: "0.0.1")
    r2 = insert(:release, project: p2, version: "0.0.1")
    r3 = insert(:release, project: p2, version: "0.0.2")
    r4 = insert(:release, project: p3, version: "0.0.2")

    %{projects: projects, releases: [r1, r2, r3, r4], team: team}
  end

  defp open_table(repo) do
    path = if repo, do: "repos/#{repo}/registry.ets.gz", else: "registry.ets.gz"

    if contents = ApxrIo.Store.get(nil, :s3_bucket, path, []) do
      contents = :zlib.gunzip(contents)
      path = Path.join(Application.get_env(:apxr_io, :tmp_dir), "registry_builder_test.ets")
      File.write!(path, contents)
      {:ok, tid} = :ets.file2tab(String.to_charlist(path))
      tid
    end
  end

  defp v2_map(path) do
    nonrepo_path = Regex.replace(~r"^repos/\w+/", path, "")

    if contents = ApxrIo.Store.get(nil, :s3_bucket, path, []) do
      public_key = Application.fetch_env!(:apxr_io, :public_key)
      {:ok, payload} = :apxr_registry.decode_and_verify_signed(:zlib.gunzip(contents), public_key)
      path_to_decoder(nonrepo_path).(payload)
    end
  end

  defp path_to_decoder("names"), do: &:apxr_registry.decode_names/1
  defp path_to_decoder("versions"), do: &:apxr_registry.decode_versions/1
  defp path_to_decoder("projects/" <> _), do: &:apxr_registry.decode_project/1

  describe "full_build/0" do
    test "registry v2 is in correct format", %{team: team, projects: [_p1, p2, p3]} do
      RegistryBuilder.full_build(team)

      project2 = v2_map("repos/#{team.name}/projects/#{p2.name}")
      assert length(project2.releases) == 2

      assert List.first(project2.releases) == %{
               version: "0.0.1",
               checksum: Base.decode16!(@checksum)
             }

      project3 = v2_map("repos/#{team.name}/projects/#{p3.name}")
      assert [%{version: "0.0.2"}] = project3.releases
    end

    test "remove project", %{team: team, projects: [p1, p2, p3], releases: [_, _, _, r4]} do
      RegistryBuilder.full_build(team)

      ApxrIo.Repo.delete!(r4)
      ApxrIo.Repo.delete!(p3)
      RegistryBuilder.full_build(team)

      assert length(v2_map("repos/#{team.name}/names").projects) == 2
      assert v2_map("repos/#{team.name}/projects/#{p1.name}")
      assert v2_map("repos/#{team.name}/projects/#{p2.name}")
      refute v2_map("repos/#{team.name}/projects/#{p3.name}")
    end

    test "registry builds for multiple repositories" do
      team = insert(:team)
      project = insert(:project, team: team)
      insert(:release, project: project, version: "0.0.1")
      RegistryBuilder.full_build(team)

      refute open_table(team.name)

      names = v2_map("repos/#{team.name}/names")
      assert length(names.projects) == 1

      assert v2_map("repos/#{team.name}/projects/#{project.name}")
    end
  end

  describe "partial_build/1" do
    test "add release", %{projects: [_, p2, _], team: team} do
      RegistryBuilder.full_build(team)

      release = insert(:release, project: p2, version: "0.0.3")

      Release.retire(release, %{retirement: %{reason: "invalid", message: "message"}})
      |> ApxrIo.Repo.update!()

      RegistryBuilder.partial_build({:publish, p2})

      refute open_table(team.name)

      versions = v2_map("repos/#{team.name}/versions")

      assert Enum.find(versions.projects, &(&1.name == p2.name)) == %{
               name: p2.name,
               versions: ["0.0.1", "0.0.2", "0.0.3"],
               retired: [2]
             }

      project = v2_map("repos/#{team.name}/projects/#{p2.name}")
      assert length(project.releases) == 3
      release = List.last(project.releases)
      assert release.version == "0.0.3"
      assert release.retired.reason == :RETIRED_INVALID
      assert release.retired.message == "message"
    end

    test "remove release", %{projects: [_, p2, _], releases: [_, _, r3, _], team: team} do
      RegistryBuilder.full_build(team)

      ApxrIo.Repo.delete!(r3)
      RegistryBuilder.partial_build({:publish, p2})

      refute open_table(team.name)

      versions = v2_map("repos/#{team.name}/versions")

      assert Enum.find(versions.projects, &(&1.name == p2.name)) == %{
               name: p2.name,
               versions: ["0.0.1"],
               retired: []
             }

      project2 = v2_map("repos/#{team.name}/projects/#{p2.name}")
      assert length(project2.releases) == 1
    end

    test "add project", %{team: team} do
      RegistryBuilder.full_build(team)

      p = insert(:project, team: team) |> ApxrIo.Repo.preload(:team)
      insert(:release, project: p, version: "0.0.1")
      RegistryBuilder.partial_build({:publish, p})

      refute open_table(team.name)

      assert length(v2_map("repos/#{team.name}/names").projects) == 4

      versions = v2_map("repos/#{team.name}/versions")

      assert Enum.find(versions.projects, &(&1.name == p.name)) == %{
               name: p.name,
               versions: ["0.0.1"],
               retired: []
             }

      ecto = v2_map("repos/#{team.name}/projects/#{p.name}")
      assert length(ecto.releases) == 1
    end

    test "remove project", %{projects: [_, _, p3], releases: [_, _, _, r4], team: team} do
      RegistryBuilder.full_build(team)

      ApxrIo.Repo.delete!(r4)
      ApxrIo.Repo.delete!(p3)
      RegistryBuilder.partial_build({:publish, p3})

      refute open_table(team.name)

      assert length(v2_map("repos/#{team.name}/names").projects) == 2
      assert length(v2_map("repos/#{team.name}/versions").projects) == 2

      refute v2_map("repos/#{team.name}/projects/#{p3.name}")
    end

    test "add project for multiple repositories" do
      team = insert(:team)
      project1 = insert(:project, team: team)
      insert(:release, project: project1, version: "0.0.1")
      RegistryBuilder.full_build(team)

      project2 = insert(:project, team: team)
      insert(:release, project: project2, version: "0.0.1")
      RegistryBuilder.partial_build({:publish, project2})

      refute open_table(team.name)

      names = v2_map("repos/#{team.name}/names")
      assert length(names.projects) == 2

      assert v2_map("repos/#{team.name}/projects/#{project1.name}")
      assert v2_map("repos/#{team.name}/projects/#{project2.name}")
    end
  end
end
