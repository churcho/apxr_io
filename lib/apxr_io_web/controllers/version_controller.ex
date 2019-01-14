defmodule ApxrIoWeb.VersionController do
  use ApxrIoWeb, :controller

  plug :requires_login

  def index(conn, %{"name" => name}) do
    user = conn.assigns.current_user
    teams = user.teams
    project = teams && Projects.get(teams, name)

    if project do
      releases = Releases.all(project)

      if releases do
        render(
          conn,
          "index.html",
          title: "#{name} versions",
          container: "container",
          releases: releases,
          project: project
        )
      end
    end || not_found(conn)
  end
end
