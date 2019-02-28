defmodule ApxrIo.ReleaseTasks do
  require Logger

  @repo_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto_sql
  ]

  @repos Application.get_env(:apxr_io, :ecto_repos, [])

  def deploy_release() do
    start_app()
    config = deploy_release_config()
    ts = create_timestamp()
    release_dir = Path.join(config.release_base, ts)
    Logger.info("Deploying release to #{release_dir}")
    File.mkdir_p!(release_dir)

    Logger.info("Extracting tarball #{config.tarball}")
    :ok = :erl_tar.extract(config.tarball, [{:cwd, release_dir}, :compressed])

    current_link = config.current_link

    if File.exists?(current_link) do
      File.rm!(current_link)
    end

    File.ln_s(release_dir, current_link)
  end

  def rollback_release() do
    start_app()
    config = deploy_release_config()
    dirs = config.release_base |> File.ls!() |> Enum.sort() |> Enum.reverse()
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

  defp start_app() do
    IO.puts("Starting app...")
    Application.put_env(:phoenix, :serve_endpoints, false, persistent: true)
    {:ok, _} = Application.ensure_all_started(:apxr_io)
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

  defp deploy_release_config() do
    app_name = Mix.Project.config()[:app] |> Atom.to_string()
    version = Mix.Project.config()[:version]
    deploy_base = "/opt"
    deploy_dir = Path.join(deploy_base, app_name)
    release_base = Path.join(deploy_dir, "releases")
    current_link = Path.join(deploy_dir, "current")

    tarball =
      Path.join([
        "_build",
        to_string(Mix.env()),
        "rel",
        app_name,
        "releases",
        version,
        "#{app_name}.tar.gz"
      ])

    %{
      app_name: app_name,
      deploy_base: deploy_base,
      deploy_dir: deploy_dir,
      release_base: release_base,
      current_link: current_link,
      tarball: tarball
    }
  end

  defp rollback_release([_current, prev | _rest], config) do
    release_dir = Path.join(config.release_base, prev)
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
