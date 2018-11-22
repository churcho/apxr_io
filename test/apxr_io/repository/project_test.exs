defmodule ApxrIo.Repository.ProjectTest do
  use ApxrIo.DataCase

  alias ApxrIo.Accounts.User
  alias ApxrIo.Repository.Project

  setup do
    user = insert(:user)
    team = insert(:team)
    %{user: user, team: team}
  end

  test "create project and get", %{user: user, team: team} do
    user_id = user.id

    Project.build(team, user, project_meta(%{name: "ecto", description: "DSL"}))
    |> ApxrIo.Repo.insert!()

    assert [%User{id: ^user_id}] =
             ApxrIo.Repo.get_by(Project, name: "ecto") |> assoc(:owners) |> ApxrIo.Repo.all()

    assert is_nil(ApxrIo.Repo.get_by(Project, name: "postgrex"))
  end

  test "update project", %{user: user, team: team} do
    project =
      Project.build(team, user, project_meta(%{name: "ecto", description: "original"}))
      |> ApxrIo.Repo.insert!()

    Project.update(project, %{
      "meta" => %{
        "description" => "updated",
        "licenses" => ["Apache"]
      }
    })
    |> ApxrIo.Repo.update!()

    project = ApxrIo.Repo.get_by(Project, name: "ecto")
    assert project.meta.description == "updated"
  end

  test "validate blank description in metadata", %{user: user, team: team} do
    changeset = Project.build(team, user, project_meta(%{name: "ecto", description: ""}))
    assert changeset.errors == []
    assert [description: {"can't be blank", _}] = changeset.changes.meta.errors
  end

  test "validate invalid link in metadata", %{user: user, team: team} do
    meta =
      project_meta(%{
        name: "ecto",
        description: "DSL",
        links: %{"docs" => "https://apxrdocs.pm", "a" => "aaa", "b" => "bbb"}
      })

    changeset = Project.build(team, user, meta)

    assert changeset.errors == []

    assert [links: {"invalid link \"aaa\"", _}, links: {"invalid link \"bbb\"", _}] =
             changeset.changes.meta.errors
  end

  test "projects are unique", %{user: user, team: team} do
    Project.build(team, user, project_meta(%{name: "ecto", description: "DSL"}))
    |> ApxrIo.Repo.insert!()

    assert {:error, _} =
             Project.build(
               team,
               user,
               project_meta(%{name: "ecto", description: "Domain-specific language"})
             )
             |> ApxrIo.Repo.insert()
  end

  test "reserved names", %{user: user, team: team} do
    assert {:error, %{errors: [name: {"is reserved", _}]}} =
             Project.build(
               team,
               user,
               project_meta(%{name: "elixir", description: "Awesomeness."})
             )
             |> ApxrIo.Repo.insert()
  end
end
