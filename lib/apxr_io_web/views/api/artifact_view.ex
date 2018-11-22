defmodule ApxrIoWeb.API.ArtifactView do
  use ApxrIoWeb, :view

  alias ApxrIo.Serve.Artifacts

  def render("index." <> _, %{artifacts: artifacts}) do
    render_many(artifacts, __MODULE__, "show")
  end

  def render("show." <> _, %{artifact: artifact}) do
    render_one(artifact, __MODULE__, "show")
  end

  def render("show", %{artifact: artifact}) do
    artifact = Artifacts.get_by_id(artifact.id)

    %{
      name: artifact.name,
      project: artifact.project.name,
      status: artifact.status,
      inserted_at: artifact.inserted_at,
      updated_at: artifact.updated_at,
      location: artifact.meta.location,
      scale_min: artifact.meta.scale_min,
      scale_max: artifact.meta.scale_max,
      scale_factor: artifact.meta.scale_factor
    }
  end
end
