defmodule ApxrIoWeb.API.AuthController do
  use ApxrIoWeb, :controller

  plug :required_params, ["domain"]
  plug :authorize

  def show(conn, %{"domain" => domain} = params) do
    key = conn.assigns.key

    user_or_team_or_af =
      conn.assigns.current_user || conn.assigns.current_team || conn.assigns.artifact

    resource = params["resource"]

    if Key.verify_permissions?(key, domain, resource) do
      case KeyPermission.verify_permissions(user_or_team_or_af, domain, resource) do
        {:ok, nil} ->
          send_resp(conn, 204, "")

        {:ok, repository_or_artifact} ->
          case team_billing_active(repository_or_artifact, nil) do
            :ok ->
              send_resp(conn, 204, "")

            error ->
              error(conn, error)
          end

        :error ->
          error(conn, {:error, :auth})
      end
    else
      error(conn, {:error, :domain})
    end
  end
end
