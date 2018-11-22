## Usage

### Installation

Mix will automatically prompt you whenever there is a need to use ApxrIo. In case you want to manually install or update apxr_io, simply run `$ mix local.apxr_io`.

### Defining dependencies

ApxrIo integrates with Mix's dependency handling. Dependencies are defined in Mix's format and all the ordinary Mix dependency commands work. In particular, all dependencies without a SCM (`:git` or `:path`) are automatically handled by ApxrIo. ApxrIo dependencies are defined in the following format:

`{:project, requirement}`

The version requirement specify which versions of the project you allow. The formats accepted for the requirement are documented in the [Version module](https://hexdocs.pm/elixir/Version.html). Below is an example `mix.exs` file.

```elixir
defmodule MyProject.MixProject do
  use Mix.Project

  def project() do
    [
      app: :my_project,
      version: "0.0.1",
      elixir: "~> 1.0",
      deps: deps(),
    ]
  end

  def application() do
    []
  end

  defp deps() do
    [
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.8.1"},
      {:cowboy, github: "ninenines/cowboy"},
    ]
  end
end
```

### Options

<dl class="dl-horizontal">
  <dt><code>:apxr_io</code></dt>
  <dd>The name of the project. Defaults to the dependency application name.</dd>
  <dt><code>:repo</code></dt>
  <dd>The repository to fetch the project from, the repository needs to be configured with the <code>mix apxr_io.repo</code> task. Defaults to the global <code>"apxr_io"</code> repository.</dd>
  <dt><code>:team</code></dt>
  <dd>The team repository to fetch the project from, the team needs to be configured with the <code>mix apxr_io.team</code> task.</dd>
</dl>

### Fetching dependencies

`$ mix deps.get` will fetch dependencies that were not already fetched. Dependency fetching is repeatable, Mix will lock the version of a dependency in the lockfile to ensure that all developers will get the same version (always commit `mix.lock` to version control). `$ mix deps.update` will update the dependency and write the updated version to the lockfile.

When Mix tries to fetch ApxrIo projects that are not locked, dependency resolution will be performed to find a set of projects that satisfies all version requirements. The resolution process will always try to use the latest version of all projects. Because of the nature of dependency resolution ApxrIo may sometimes fail to find a compatible set of dependencies. This can be resolved by unlocking dependencies with `$ mix deps.unlock`, more unlocked dependencies give ApxrIo a larger selection of project versions to work with.
