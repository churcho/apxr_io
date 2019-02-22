defmodule ApxrIo.MixProject do
  use Mix.Project

  def project do
    [
      app: :apxr_io,
      version: "0.0.1",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      xref: xref(),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_deps: :transitive,
        plt_add_apps: [:ex_unit],
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        check: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  def application do
    [
      mod: {ApxrIo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp xref() do
    [exclude: [ApxrSh.Registry]]
  end

  # Specifies your project dependencies.
  defp deps do
    [
      # Email library - MIT
      {:bamboo, "~> 1.2"},
      # Encrypted fields for Ecto - MIT
      {:cloak, "~> 0.9.1"},
      # Plug-based swiss-army knife for CORS requests - MIT
      {:corsica, "~> 1.0"},
      # static code analysis tool - MIT
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      # Mix tasks to simplify use of Dialyzer in Elixir projects - Apache 2.0
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      # Build releases tool - MIT
      {:distillery, "~> 2.0.3"},
      # S3 service package - MIT
      {:ex_aws_s3, "~> 2.0"},
      # SES service package - MIT
      {:ex_aws_ses, "~> 2.0"},
      # AWS client - MIT
      {:ex_aws, "~> 2.0"},
      # Coverage report tool for Elixir - MIT
      {:excoveralls, "~> 0.10", only: :test},
      # Factory library - MIT
      {:ex_machina, "~> 2.0"},
      # SQL-based adapters for Ecto and database migrations - Apache 2.0
      {:ecto_sql, "~> 3.0.5"},
      # Simple HTTP client - Apache 2.0
      {:hackney, "~> 1.15.1"},
      # JSON parser and generator - Apache 2.0
      {:jason, "~> 1.1"},
      # Elixir JWT library - Apache 2.0
      {:joken, "~> 2.0.1"},
      # Easily parsable single line, plain text and JSON logger - MIT
      {:logster, "~> 0.10.0"},
      # Mocks and explicit contracts for Elixir - Apache 2.0
      {:mox, "~> 0.5.0", only: :test},
      # Visualize Erlang/Elixir Nodes On The Command Line - MIT
      {:observer_cli, "~> 1.4.2"},
      # Integration between Phoenix & Ecto - Apache 2.0
      {:phoenix_ecto, "~> 4.0"},
      # Functions for working with HTML strings and templates - MIT
      {:phoenix_html, "~> 2.3"},
      # Live-reload functionality for Phoenix - MIT
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      # Web framework - MIT
      {:phoenix, "~> 1.4.0"},
      # Plug building toolkit for blocking and throttling - Apache 2.0
      {:plug_attack, "~> 0.3"},
      # A Plug adapter for Cowboy - Apache 2.0
      {:plug_cowboy, "~> 2.0"},
      # Specification and conveniences for composable modules between web applications - Apache 2.0
      {:plug, "~> 1.7"},
      # An incredibly fast, pure Elixir JSON library - CC0-1.0
      {:poison, "~> 3.0"},
      # PostgreSQL driver - Apache 2.0
      {:postgrex, "~> 0.14"},
      # Wrapper of :xmerl to help query xml docs - Apache 2.0
      {:sweet_xml, "~> 0.6.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases() do
    [
      "ecto.setup": ["ecto.reset", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.create", "ecto.migrate"],
      setup: ["deps.get", "ecto.setup", &setup_yarn/1],
      test: ["ecto.reset", "test"],
      check: [
        "deps.get",
        "hex.outdated",
        "compile",
        "format",
        "xref unreachable",
        "dialyzer",
        "test --cover"
      ]
    ]
  end

  defp setup_yarn(_) do
    cmd("yarn", ["install"], cd: "assets")
  end

  defp cmd(cmd, args, opts) do
    opts = Keyword.merge([into: IO.stream(:stdio, :line), stderr_to_stdout: true], opts)
    {_, result} = System.cmd(cmd, args, opts)

    if result != 0 do
      raise "Non-zero result (#{result}) from: #{cmd} #{Enum.map_join(args, " ", &inspect/1)}"
    end
  end
end
