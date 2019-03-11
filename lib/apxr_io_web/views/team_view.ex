defmodule ApxrIoWeb.TeamView do
  use ApxrIoWeb, :view

  defp team_roles_selector() do
    Enum.map(team_roles(), fn {name, id, _title} ->
      {name, id}
    end)
  end

  defp team_roles() do
    [
      {"Admin", "admin", "This role has full control of the team"},
      {"Write", "write", "This role has project owner access to all team projects"},
      {"Read", "read", "This role can fetch all team projects"}
    ]
  end

  defp team_role(id) do
    Enum.find_value(team_roles(), fn {name, team_id, _title} ->
      if id == team_id do
        name
      end
    end)
  end

  def extract_params("key.generate", params) do
    Map.to_list(%{name: params["key"]["name"]})
  end

  def extract_params("key.remove", params) do
    Map.to_list(%{name: params["key"]["name"]})
  end

  def extract_params("owner.add", params) do
    Map.to_list(%{
      project: params["project"]["name"],
      level: params["level"],
      user: params["user"]["username"]
    })
  end

  def extract_params("owner.remove", params) do
    Map.to_list(%{
      project: params["project"]["name"],
      level: params["level"],
      user: params["user"]["username"]
    })
  end

  def extract_params("release.publish", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("release.revert", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("release.retire", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("release.unretire", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("email.add", params) do
    Map.to_list(%{email: params["email"], primary: params["primary"]})
  end

  def extract_params("email.remove", params) do
    Map.to_list(%{email: params["email"], primary: params["primary"]})
  end

  def extract_params("email.primary", params) do
    Map.to_list(%{
      old_email: params["old_email"]["email"],
      new_email: params["new_email"]["email"]
    })
  end

  def extract_params("user.create", params) do
    Map.to_list(%{user: params["user"]["username"]})
  end

  def extract_params("user.update", params) do
    Map.to_list(%{user: params["user"]["username"]})
  end

  def extract_params("team.create", params) do
    Map.to_list(%{team: params["team"]["name"]})
  end

  def extract_params("team.member.add", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.member.remove", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.member.role", params) do
    Map.to_list(%{
      team: params["team"]["name"],
      user: params["user"]["username"],
      role: params["role"]
    })
  end

  def extract_params("experiment.create", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.start", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.pause", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.continue", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.stop", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.update", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.delete", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("artifact.publish", params) do
    Map.to_list(%{project: params["project"]["name"], artifact: params["artifact"]["name"]})
  end

  def extract_params("artifact.unpublish", params) do
    Map.to_list(%{project: params["project"]["name"], artifact: params["artifact"]["name"]})
  end

  def extract_params("artifact.delete", params) do
    Map.to_list(%{project: params["project"]["name"], artifact: params["artifact"]["name"]})
  end

  def extract_params(_unknown_action, _params) do
    Map.to_list(%{})
  end
end
