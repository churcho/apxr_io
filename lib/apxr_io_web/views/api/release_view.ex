defmodule ApxrIoWeb.API.ReleaseView do
  use ApxrIoWeb, :view
  alias ApxrIoWeb.API.RetirementView

  def render("show." <> _, %{release: release}) do
    render_one(release, __MODULE__, "show")
  end

  def render("minimal." <> _, %{release: release, project: project}) do
    render_one(release, __MODULE__, "minimal", %{project: project})
  end

  def render("show", %{release: release}) do
    %{
      version: release.version,
      inserted_at: release.inserted_at,
      updated_at: release.updated_at,
      retirement: render_one(release.retirement, RetirementView, "show.json"),
      meta: %{
        build_tool: release.meta.build_tool,
        build_tool_version: release.meta.build_tool_version
      }
    }
  end

  def render("minimal", %{release: release, project: _project}) do
    %{
      version: release.version
    }
  end
end
