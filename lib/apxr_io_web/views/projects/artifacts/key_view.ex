defmodule ApxrIoWeb.Projects.Artifacts.KeyView do
  use ApxrIoWeb, :view

  def permission_name(%KeyPermission{domain: "repository", resource: resource}) do
    "ARTIFACT:#{resource}"
  end

  def artifact_resources(%{artifact: artifact}) do
    [artifact.name]
  end
end
