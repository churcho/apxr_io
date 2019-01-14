defmodule ApxrIo.MixProject do
  use Mix.Project

  def project do
    [
      app: :apxr_io,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      xref: xref(),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
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
      {:bamboo, "~> 1.0"},
      # Encrypted fields for Ecto - MIT
      {:cloak, "~> 0.9.1"},
      # Plug-based swiss-army knife for CORS requests - MIT
      {:corsica, "~> 1.0"},
      # static code analysis tool - MIT
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      # Build releases tool - MIT
      {:distillery, "~> 1.5", runtime: false},
      # Markdown converter - Apache 2.0
      {:earmark, "~> 1.0"},
      # S3 service package - MIT
      {:ex_aws_s3, "~> 2.0"},
      # SES service package - MIT
      {:ex_aws_ses, "~> 2.0"},
      # AWS client - MIT
      {:ex_aws, "~> 2.0"},
      # Factory library - MIT
      {:ex_machina, "~> 2.0"},
      # Data mapping and language integrated query - Apache 2.0
      {:ecto, "~> 3.0", override: true},
      # SQL-based adapters for Ecto and database migrations - Apache 2.0
      {:ecto_sql, "~> 3.0"},
      # Simple HTTP client - Apache 2.0
      {:hackney, "~> 1.7"},
      # JSON parser and generator - Apache 2.0
      {:jason, "~> 1.1"},
      # Automatic Erlang cluster formation and management for - Apache 2.0
      {:libcluster, "~> 3.0"},
      # Easily parsable single line, plain text and JSON logger - MIT
      {:logster, "~> 0.10.0"},
      # Mocks and explicit contracts for Elixir - Apache 2.0
      {:mox, "~> 0.3.1", only: :test},
      # Integration between Phoenix & Ecto - Apache 2.0
      {:phoenix_ecto, "~> 3.1"},
      # Functions for working with HTML strings and templates - MIT
      {:phoenix_html, "~> 2.3"},
      # Live-reload functionality for Phoenix - MIT
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      # Distributed PubSub and Presence platform - MIT
      {:phoenix_pubsub, "~> 1.0"},
      # Web framework - MIT
      {:phoenix, "~> 1.3"},
      # Plug building toolkit for blocking and throttling - Apache 2.0
      {:plug_attack, "~> 0.3"},
      # Plug adapter for Cowboy - Apache 2.0
      {:plug_cowboy, "~> 1.0"},
      # Specification and conveniences for composable modules between web applications - Apache 2.0
      {:plug, "~> 1.2"},
      # PostgreSQL driver - Apache 2.0
      {:postgrex, "~> 0.14"},
      # Wrapper of :xmerl to help query xml docs - Apache 2.0
      {:sweet_xml, "~> 0.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases() do
    [
      setup: ["deps.get", "ecto.setup", &setup_yarn/1],
      "ecto.setup": ["ecto.reset", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.create", "ecto.migrate"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
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
