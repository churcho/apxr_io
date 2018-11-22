defmodule ApxrIo.Case do
  import ExUnit.Callbacks

  def reset_store() do
    if Application.get_env(:apxr_io, :s3_bucket) do
      Application.put_env(:apxr_io, :store_impl, ApxrIo.Store.S3)
      on_exit(fn -> Application.put_env(:apxr_io, :store_impl, ApxrIo.Store.Local) end)
    end
  end

  def create_user(username, email, confirmed? \\ true) do
    ApxrIo.Accounts.User.build(
      %{username: username, emails: [%{email: email}]},
      confirmed?
    )
    |> ApxrIo.Repo.insert!()
  end

  def key_for(user_or_team) do
    key =
      user_or_team
      |> ApxrIo.Accounts.Key.build(%{name: "any_key_name"})
      |> ApxrIo.Repo.insert!()

    key.user_secret
  end

  def read_fixture(path) do
    Path.join([__DIR__, "..", "fixtures", path])
    |> File.read!()
  end

  def audit_data(user) do
    {user, "TEST", "0.0.0.0"}
  end
end
