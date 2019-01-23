defmodule ApxrIo.Learn.ExperimentGraphData do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  embedded_schema do
    field :avg_fitness_vs_evaluations, :map
    field :avg_neurons_vs_evaluations, :map
    field :avg_diversity_vs_evaluations, :map
    field :max_fitness_vs_evaluations, :map
    field :avg_max_fitness_vs_evaluations, :map
    field :avg_min_fitness_vs_evaluations, :map
    field :specie_pop_turnover_vs_evaluations, :map
    field :validation_avg_fitness_vs_evaluations, :map
    field :validation_max_fitness_vs_evaluations, :map
    field :validation_min_fitness_vs_evaluations, :map
  end

  def changeset(graph, params) do
    cast(graph, params, ~w(avg_fitness_vs_evaluations avg_neurons_vs_evaluations
      avg_diversity_vs_evaluations avg_max_fitness_vs_evaluations
      avg_min_fitness_vs_evaluations specie_pop_turnover_vs_evaluations
      validation_avg_fitness_vs_evaluations validation_max_fitness_vs_evaluations
      validation_min_fitness_vs_evaluations)a)
  end
end
