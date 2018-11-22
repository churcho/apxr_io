## Private projects and teams

With an team you can publish and fetch private projects from approximatereality.com and you can control exactly which users have access to the projects. To administer any teams you are a member of go to the [settings](/settings). Go to the [sign up form](/settings/repo-signup) to create an team.

### Add an team to Mix

The team's projects are namespaced under the team's repository. Only members of the team have access to the repository's projects, to get access in Mix you need to authorize the team with the `mix apxr_io.team` task. Run the following command to do so:

```nohighlight
$ mix apxr_io.team auth acme
```

To run this command you need to have an authenticated user on your local machine, run `$ mix apxr_io.user register` to register or `$ mix apxr_io.user auth` to authenticate with an existing user.

### Publishing a private project

To publish a project simply to your team add the `--team` flag to the `$ mix apxr_io.publish --team acme` command. You can also configure a project to belong to a specific team, add the `team: "acme"` option to the project configuration:

```elixir
defp project() do
  [
    team: "acme",
    ...
  ]
end
```

### Using private projects as dependencies

A private project can only depend on projects from its own repository and from the global `"apxr_io"` repository where all public projects belong. You specify a project should be fetched from a specific team's repository with the `:team` option on the dependency declaration, if this option is not included it is assumed the project belongs to the global repository. For example:

```elixir
defp deps() do
  [
    # This project will be fetched from the global repository
    {:ecto, "~> 2.0"},
    # This project will be fetched from the acme team's repository
    {:secret, "~> 1.0", team: "acme"},
  ]
end
```

### Authenticating on CI and build servers

You can generate repository authentication keys manually with the `mix apxr_io.team key` task. This can then be used to fetch projects on your CI servers without requiring manual authentication with username and password.

Run the following command on your local machine:

```nohighlight
$ mix apxr_io.team key acme generate
Passphrase: ...
126d49fb3014bd26457471ebae97c625
```

You can also generate teams keys on your team's [settings](/settings).

Copy the returned hash and authenticate with it on your build server:

```nohighlight
$ mix apxr_io.team auth acme --key 126d49fb3014bd26457471ebae97c625
```
