defmodule ApxrIo.Learn.ExperimentGraphData do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  embedded_schema do
    field :fitness_vs_evals, :map
    field :val_fitness_vs_evals, :map
    field :specie_pop_turnover_vs_evals, :map
    field :avg_fitness_vs_evals_std, :map
    field :avg_val_fitness_vs_evals_std, :map
    field :avg_neurons_vs_evals_std, :map
    field :avg_diversity_vs_evals_std, :map
  end

  def changeset(graph, params) do
    cast(graph, params, ~w(fitness_vs_evals val_fitness_vs_evals
      specie_pop_turnover_vs_evals avg_fitness_vs_evals_std
      avg_val_fitness_vs_evals_std avg_neurons_vs_evals_std
      avg_diversity_vs_evals_std)a)
    |> validate_required(~w(fitness_vs_evals)a)
    |> validate_required(~w(val_fitness_vs_evals)a)
    |> validate_required(~w(specie_pop_turnover_vs_evals)a)
    |> validate_required(~w(avg_fitness_vs_evals_std)a)
    |> validate_required(~w(avg_val_fitness_vs_evals_std)a)
    |> validate_required(~w(avg_neurons_vs_evals_std)a)
    |> validate_required(~w(avg_diversity_vs_evals_std)a)
  end
end
