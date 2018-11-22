defmodule ApxrIoWeb.API.ExperimentView do
  use ApxrIoWeb, :view

  alias ApxrIo.Learn.Experiments

  def render("index." <> _, %{experiments: experiments}) do
    render_many(experiments, __MODULE__, "show")
  end

  def render("show." <> _, %{experiment: experiment}) do
    render_one(experiment, __MODULE__, "show")
  end

  def render("show", %{experiment: experiment}) do
    experiment = Experiments.get_by_id(experiment.id)

    %{
      id: experiment.id,
      description: experiment.description,
      inserted_at: experiment.inserted_at,
      updated_at: experiment.updated_at,
      version: experiment.release.version
    }
  end
end
