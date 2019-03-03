defmodule ApxrIoWeb.HealthChecks do
  def check_db do
    user_id = 1

    case ApxrIo.Accounts.Users.get_by_id(user_id) do
      %ApxrIo.Accounts.User{} ->
        :ok

      _ ->
        {:error, "health check failed"}
    end
  end
end
