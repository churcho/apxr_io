defmodule ApxrIoWeb.Settings.ProfileController do
  use ApxrIoWeb, :controller

  plug :requires_login

  @logs_per_page 10

  def index(conn, _params) do
    user = conn.assigns.current_user
    render_index(conn, User.update_profile(user, %{}))
  end

  def audit_log(conn, params) do
    user = conn.assigns.current_user
    render_audit_log(conn, user, params)
  end

  def export_data(conn, _params) do
    user = conn.assigns.current_user
    data = Users.put_data_dump(user)

    json(conn, data)
  end

  defp render_audit_log(conn, user, params) do
    page_param = ApxrIo.Utils.safe_int(params["page"]) || 1
    log_count = ApxrIo.Accounts.AuditLogs.count(user)
    page = ApxrIo.Utils.safe_page(page_param, log_count, @logs_per_page)
    audit_log = ApxrIo.Accounts.AuditLogs.all_by_user_or_team(user, page, @logs_per_page)

    render(
      conn,
      "layout.html",
      view: "audit_log.html",
      view_name: :audit_log,
      title: "Audit log",
      container: "container page settings",
      per_page: @logs_per_page,
      audit_log_count: log_count,
      page: page,
      user: user,
      audit_log: audit_log
    )
  end

  def update(conn, params) do
    user = conn.assigns.current_user

    case Users.update_profile(user, params["user"], audit: audit_data(conn)) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Profile updated successfully.")
        |> redirect(to: Routes.profile_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render_index(changeset)
    end
  end

  defp render_index(conn, changeset) do
    render(
      conn,
      "layout.html",
      view: "index.html",
      view_name: :index,
      title: "Profile",
      container: "container page settings",
      changeset: changeset,
      user: conn.assigns.current_user
    )
  end
end
