defmodule ApxrIo.Repository.Assets do
  alias ApxrIo.Accounts.Teams

  def push_release(release, body) do
    opts = [cache_control: "private, max-age=0"]

    ApxrIo.Store.put(nil, :s3_bucket, tarball_store_key(release), body, opts)
  end

  def get_release(release) do
    ApxrIo.Store.get(nil, :s3_bucket, tarball_store_key(release), [])
  end

  def revert_release(release) do
    ApxrIo.Store.delete(nil, :s3_bucket, tarball_store_key(release))
  end

  defp tarball_store_key(release) do
    "#{repository_store_key(release)}tarballs/#{release.project.name}-#{release.version}.tar"
  end

  defp repository_store_key(release) do
    team = Teams.get_by_id(release.project.team_id)

    "repos/#{team.name}/"
  end
end
