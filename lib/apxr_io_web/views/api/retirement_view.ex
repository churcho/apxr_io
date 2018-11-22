defmodule ApxrIoWeb.API.RetirementView do
  use ApxrIoWeb, :view

  def render("show." <> _, %{retirement: retirement}) do
    render_one(retirement, __MODULE__, "show")
  end

  def render("project." <> _, %{retirement: retirement}) do
    render_one(retirement, __MODULE__, "project")
  end

  def render("show", %{retirement: retirement}) do
    %{
      message: retirement.message,
      reason: retirement.reason
    }
  end

  def render("project", %{retirement: %{retirement: nil}}), do: %{}

  def render("project", %{retirement: %{retirement: retirement, version: version}}) do
    %{
      version => %{reason: retirement.reason, message: retirement.message}
    }
  end
end
