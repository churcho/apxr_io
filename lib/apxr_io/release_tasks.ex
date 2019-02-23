defmodule ApxrIo.ReleaseTasks do
  require Logger

  @repo_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto_sql
  ]

  @repos Application.get_env(:apxr_io, :ecto_repos, [])

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
    Enum.each(@repos, &run_migrations_for/1)
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

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config(), :otp_app)
    IO.puts("Running migrations for #{app}")
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
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

  defp run_script() do
    [script | args] = argv()
    System.argv(args)

    priv_dir = Application.app_dir(:apxr_io, "priv")
    script_dir = Path.join(priv_dir, "scripts")

    Logger.info("[script] running #{script} #{inspect(args)}")
    Code.eval_file(script, script_dir)
    Logger.info("[script] finished #{script} #{inspect(args)}")
  end

  defp argv() do
    Enum.map(:init.get_plain_arguments(), &List.to_string/1)
  end
end
