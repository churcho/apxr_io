defmodule ApxrIo.ReleaseTasks do
  require Logger

  @app_name Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]
  @build_path Mix.Project.build_path()

  @repo_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto_sql
  ]

  @repos Application.get_env(:apxr_io, :ecto_repos, [])

  def deploy_release() do
    config = deploy_release_config()
    ts = create_timestamp()
    release_dir = Path.join(config.release_dir, ts)
    Logger.info("Deploying release to #{release_dir}")
    :ok = File.mkdir_p(release_dir)

    app = config.app_name
    tar_file = Path.join([config.build_path, "rel", app, "releases", config.version, "#{app}.tar.gz"])
    Logger.info("Extracting tar #{tar_file}")
    :ok = :erl_tar.extract(to_charlist(tar_file), [{:cwd, release_dir}, :compressed])

    current_link = config.current_link
    if File.exists?(current_link) do
      File.rm(current_link)
    end

    File.ln_s(release_dir, current_link)
  end

  def rollback_release() do
    config = deploy_release_config()
    dirs = config.release_dir |> File.ls!() |> Enum.sort() |> Enum.reverse()
    rollback_release(dirs, config)
  end

  def migrate() do
    {:ok, _} = Application.ensure_all_started(:logger)
    Logger.info("[task] running migrate")
    start_repo()

    run_migrations()

    Logger.info("[task] finished migrate")
    stop()
  end

  def rollback() do
    {:ok, _} = Application.ensure_all_started(:logger)
    Logger.info("[task] running rollback")
    start_repo()

    run_rollback()

    Logger.info("[task] finished rollback")
    stop()
  end

  def seed() do
    {:ok, _} = Application.ensure_all_started(:logger)
    Logger.info("[task] running seed")
    start_repo()

    run_migrations()
    run_seeds()

    Logger.info("[task] finished seed")
    stop()
  end

  defp start_repo() do
    IO.puts("Starting dependencies...")

    Enum.each(@repo_apps, fn app ->
      {:ok, _} = Application.ensure_all_started(app)
    end)

    IO.puts("Starting repos...")
    :ok = Application.load(:apxr_io)

    Enum.each(@repos, fn repo ->
      {:ok, _} = repo.start_link(pool_size: 2)
    end)
  end

  defp stop() do
    IO.puts("Stopping...")
    :init.stop()
  end

  defp run_migrations() do
    Enum.each(@repos, fn repo ->
      app = Keyword.get(repo.config(), :otp_app)
      IO.puts("Running migrations for #{app}")

      case argv() do
        ["--step", n] -> migrate(repo, :up, step: String.to_integer(n))
        ["-n", n] -> migrate(repo, :up, step: String.to_integer(n))
        ["--to", to] -> migrate(repo, :up, to: to)
        ["--all"] -> migrate(repo, :up, all: true)
        [] -> migrate(repo, :up, all: true)
      end
    end)
  end

  defp run_rollback() do
    Enum.each(@repos, fn repo ->
      app = Keyword.get(repo.config(), :otp_app)
      IO.puts("Running rollback for #{app}")

      case argv() do
        ["--step", n] -> migrate(repo, :down, step: String.to_integer(n))
        ["-n", n] -> migrate(repo, :down, step: String.to_integer(n))
        ["--to", to] -> migrate(repo, :down, to: to)
        ["--all"] -> migrate(repo, :down, all: true)
        [] -> migrate(repo, :down, step: 1)
      end
    end)
  end

  defp migrate(repo, direction, opts) do
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, direction, opts)
  end

  defp run_seeds() do
    Enum.each(@repos, &run_seeds_for/1)
  end

  defp run_seeds_for(repo) do
    # Run the seed script if it exists
    seed_script = priv_path_for(repo, "seeds.exs")

    if File.exists?(seed_script) do
      IO.puts("Running seed script...")
      Code.eval_file(seed_script)
    end
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config(), :otp_app)
    priv_dir = Application.app_dir(app, "priv")
    Path.join([priv_dir, "repo", filename])
  end

  defp argv() do
    Enum.map(:init.get_plain_arguments(), &List.to_string/1)
  end

  defp create_timestamp do
    {{year, month, day}, {hour, minute, second}} =
      :calendar.now_to_universal_time(:os.timestamp())

    timestamp =
      :io_lib.format("~4..0B~2..0B~2..0B~2..0B~2..0B~2..0B", [
        year,
        month,
        day,
        hour,
        minute,
        second
      ])

    timestamp |> List.flatten() |> to_string
  end

  defp app_name(), do: @app_name |> to_string
  defp version(), do: @version |> to_string
  defp build_path(), do: @build_path |> to_string

  defp deploy_release_config() do
    app_name = app_name()
    version = version()
    build_path = build_path()
    deploy_base = "/srv"
    ext_name = app_name |> String.replace("_", "-")
    deploy_dir = Path.join([File.cwd!(), deploy_base, ext_name])
    release_dir = Path.join(deploy_dir, "releases")
    current_link = Path.join(deploy_dir, "current")

    %{
      app_name: app_name,
      ext_name: ext_name,
      version: version,
      build_path: build_path,
      deploy_dir: deploy_dir,
      release_dir: release_dir,
      current_link: current_link
    }
  end

  defp rollback_release([_current, prev | _rest], config) do
    release_dir = Path.join(config.release_dir, prev)
    remove_current_link(config)
    Logger.info("Making link from #{release_dir} to #{config.current_link}")
    File.ln_s(release_dir, config.current_link)
  end

  defp rollback_release(dirs, _config) do
    Logger.info("Nothing to roll back to: releases = #{inspect(dirs)}")
  end

  defp remove_current_link(config) do
    case File.read_link(config.current_link) do
      {:ok, target} ->
        Logger.info("Removing link from #{target} to #{config.current_link}")
        :ok = File.rm(config.current_link)

      {:error, _reason} ->
        Logger.info("No current link #{config.current_link}")
    end
  end
end
