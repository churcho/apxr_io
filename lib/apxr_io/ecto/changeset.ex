defmodule ApxrIo.Changeset do
  @moduledoc """
  Ecto changeset helpers.
  """

  import Ecto.Changeset

  @doc """
  Checks if a version is valid semver.
  """
  def validate_version(changeset, field) do
    validate_change(changeset, field, fn
      _, %Version{build: nil} ->
        []

      _, %Version{} ->
        [{field, "build number not allowed"}]
    end)
  end

  def validate_list_required(changeset, field) do
    validate_change(changeset, field, fn
      _, [] ->
        [{field, "can't be blank"}]

      _, list when is_list(list) ->
        []
    end)
  end

  def validate_verified_email_exists(changeset, field, opts) do
    validate_change(changeset, field, fn _, email ->
      case ApxrIo.Repo.get_by(ApxrIo.Accounts.Email, email: email, verified: true) do
        nil ->
          []

        _ ->
          [{field, opts[:message]}]
      end
    end)
  end

  def validate_repository(changeset, field, opts) do
    validate_change(changeset, field, fn key, dependency_repository ->
      team = Keyword.fetch!(opts, :repository)

      if dependency_repository in ["apxr_io", team.name] do
        []
      else
        [{key, {repository_error(team, dependency_repository), []}}]
      end
    end)
  end

  defp repository_error(%{id: 1}, dependency_repository) do
    "dependencies can only belong to public repository \"apxr_io\", " <>
      "got: #{inspect(dependency_repository)}"
  end

  defp repository_error(%{name: name}, dependency_repository) do
    "dependencies can only belong to public repository \"apxr_io\" " <>
      "or current repository #{inspect(name)}, got: #{inspect(dependency_repository)}"
  end

  def put_default_embed(changeset, key, value) do
    if get_change(changeset, key) do
      changeset
    else
      put_embed(changeset, key, value)
    end
  end
end
