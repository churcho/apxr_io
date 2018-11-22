defmodule ApxrIo.Repository.Installs do
  use ApxrIoWeb, :context

  def all() do
    Repo.all(Install.all())
  end

  def all_versions() do
    Repo.all(Install.all_versions())
  end
end
