import ApxrIo.Factory

ApxrIo.Fake.start()

lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
  tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."

ApxrIo.Repo.transaction(fn ->
  myrepo = insert(:team, name: "myrepo")

  eric_email = "eric@example.com"
  jose_email = "jose@example.com"
  joe_email = "joe@example.com"

  insert(
    :post
  )

  insert(
    :post,
    title: "Unpublished",
    slug: "un-published",
    published: false
  )

  eric =
    insert(
      :user,
      username: "eric",
      emails: [build(:email, email: eric_email, email_hash: eric_email)]
    )

  jose =
    insert(
      :user,
      username: "jose",
      emails: [build(:email, email: jose_email, email_hash: jose_email)]
    )

  joe =
    insert(
      :user,
      username: "joe",
      emails: [build(:email, email: joe_email, email_hash: joe_email)]
    )

  insert(:team_user, team: myrepo, user: eric, role: "admin")
  insert(:team_user, team: myrepo, user: jose, role: "write")
  insert(:team_user, team: myrepo, user: joe, role: "write")

  decimal =
    insert(
      :project,
      team_id: myrepo.id,
      project_owners: [build(:project_owner, user: eric)],
      meta:
        build(
          :project_metadata,
          licenses: ["Apache 2.0", "MIT"],
          links: %{"Github" => "http://example.com/github"},
          description: "Arbitrary precision decimal arithmetic for Elixir"
        )
    )

  insert(
    :release,
    project: decimal,
    version: "0.0.1",
    meta:
      build(
        :release_metadata,
        build_tool: "python",
        build_tool_version: 3.0
      )
  )

  insert(
    :release,
    project: decimal,
    version: "0.0.2",
    meta:
      build(
        :release_metadata,
        build_tool: "python",
        build_tool_version: 3.0
      )
  )

  insert(
    :release,
    project: decimal,
    version: "0.1.0",
    meta:
      build(
        :release_metadata,
        build_tool: "python",
        build_tool_version: 3.0
      )
  )

  postgrex =
    insert(
      :project,
      team_id: myrepo.id,
      name: "postgrex",
      project_owners: [build(:project_owner, user: eric), build(:project_owner, user: jose)],
      meta:
        build(
          :project_metadata,
          licenses: ["Apache 2.0"],
          links: %{"Github" => "http://example.com/github"},
          description: lorem
        )
    )

  insert(
    :release,
    project: postgrex,
    version: "0.0.1",
    meta:
      build(
        :release_metadata,
        build_tool: "python"
      )
  )

  insert(
    :release,
    project: postgrex,
    version: "0.0.2",
    meta:
      build(
        :release_metadata,
        build_tool: "python"
      )
  )

  insert(
    :release,
    project: postgrex,
    version: "0.1.0",
    meta:
      build(
        :release_metadata,
        build_tool: "elixir"
      )
  )

  ecto =
    insert(
      :project,
      team_id: myrepo.id,
      name: "ecto",
      project_owners: [build(:project_owner, user: jose)],
      meta:
        build(
          :project_metadata,
          licenses: [],
          links: %{"Github" => "http://example.com/github"},
          description: lorem
        )
    )

  insert(
    :release,
    project: ecto,
    version: "0.0.1",
    meta:
      build(
        :release_metadata,
        build_tool: "elixir"
      )
  )

  insert(
    :release,
    project: ecto,
    version: "0.0.2",
    meta:
      build(
        :release_metadata,
        build_tool: "elixir"
      )
  )

  ecto_rel4 =
    insert(
      :release,
      project: ecto,
      version: "0.1.0",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  ecto_rel3 =
    insert(
      :release,
      project: ecto,
      version: "0.1.1",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  ecto_rel2 =
    insert(
      :release,
      project: ecto,
      version: "0.1.2",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  ecto_rel1 =
    insert(
      :release,
      project: ecto,
      version: "0.1.3",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  ecto_rel =
    insert(
      :release,
      project: ecto,
      version: "0.2.0",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  private =
    insert(
      :project,
      team_id: myrepo.id,
      name: "private",
      project_owners: [build(:project_owner, user: eric)],
      meta:
        build(
          :project_metadata,
          licenses: [],
          links: %{"Github" => "http://example.com/github"},
          description: lorem
        )
    )

  insert(
    :release,
    project: private,
    version: "0.0.1",
    meta:
      build(
        :release_metadata,
        build_tool: "elixir"
      )
  )

  ecto_exp =
    insert(
      :experiment,
      release: ecto_rel
    )

  ecto_exp1 =
    insert(
      :experiment,
      release: ecto_rel1
    )

  ecto_exp2 =
    insert(
      :experiment,
      release: ecto_rel2
    )

  insert(
    :experiment,
    release: ecto_rel3
  )

  ecto_exp4 =
    insert(
      :experiment,
      release: ecto_rel4
    )

  insert(
    :artifact,
    experiment: ecto_exp,
    project: ecto,
    status: "offline"
  )

  insert(
    :artifact,
    experiment: ecto_exp1,
    project: ecto
  )

  insert(
    :artifact,
    experiment: ecto_exp2,
    project: ecto
  )

  insert(
    :artifact,
    experiment: ecto_exp4,
    project: ecto,
    status: "online"
  )

  insert(
    :artifact,
    experiment: ecto_exp4,
    project: ecto,
    status: "offline"
  )
end)
