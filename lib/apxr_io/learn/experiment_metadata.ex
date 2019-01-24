defmodule ApxrIo.Learn.ExperimentMetadata do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  @params ~w(identifier started completed duration progress
  interruptions init_constraints pm_parameters exp_parameters total_runs)a

  @reserved_names ~w(all)

  embedded_schema do
    field :identifier, :string
    field :started, :string
    field :completed, :string
    field :duration, :integer
    field :progress, :string
    field :total_runs, :integer
    field :interruptions, {:array, :integer}
    field :exp_parameters, :map
    field :pm_parameters, :map
    field :init_constraints, {:array, :map}
  end

  def changeset(meta, params) do
    cast(meta, params, @params)
    |> validate_exclusion(:identifier, @reserved_names)
    |> validate_inclusion(:progress, ~w(paused, in_progress completed))
    |> validate_exp_parameters(:exp_parameters)
    |> validate_pm_parameters(:pm_parameters)
    |> validate_init_constraints(:init_constraints)
  end

  defp validate_exp_parameters(changeset, field) do
    case changeset.valid? do
      true ->
        exp_parameters = get_field(changeset, field)
        
        case exp_parameters_validator(exp_parameters) do
          [] ->
            changeset
          errors ->
            [add_error(changeset, :exp_parameters, e) || e <- errors]
        end
      _ ->
        changeset
    end
  end

  defp exp_parameters_validator(exp_parameters) ->
    Enum.reduce(exp_parameters, [], fn {k, v}, acc ->
      case k do
        :public_scape ->
          validate_public_scape(v, acc)
        :runs ->
          validate_runs(v, acc)
        :min_pimprovement ->
          validate_min_pimprovement(v, acc)
        :search_params_mut_prob ->
          validate_search_params_mut_prob(v, acc)
        :output_sat_limit ->
          validate_output_sat_limit(v, acc)
        :ro_signal ->
          validate_ro_signal(v, acc)
        :fitness_stagnation ->
          validate_fitness_stagnation(v, acc)
        :population_mgr_efficiency ->
          validate_population_mgr_efficiency(v, acc)
        :interactive_selection ->
          validate_interactive_selection(v, acc)
        :re_entry_probability ->
          validate_re_entry_probability(v, acc)
        :shof_ratio ->
          validate_shof_ratio(v, acc)
        :selection_algorithm_efficiency ->
          validate_selection_algorithm_efficiency(v, acc)
        _ ->
          acc
      end
    end)
  end

  defp validate_public_scape(v, acc) when v == [] do
    acc
  end

  def validate_public_scape([x, y, w, h, scape], acc)
  when is_float(x), is_float(y), is_float(w), is_float(h), is_atom(scape) do
    acc
  end

  def validate_public_scape(_v, acc) do
    ["public_scape invalid" | acc]
  end

  defp validate_runs(v, acc) when is_integer(v) and v > 0 do
    acc
  end

  defp validate_runs(_v, acc) do
    ["runs invalid" | acc]
  end

  defp validate_min_pimprovement(v, acc) when is_float(v) do
    acc
  end

  defp validate_min_pimprovement(_v, acc) do
    ["min_pimprovement invalid" | acc]
  end

  defp validate_search_params_mut_prob(v, acc) when is_float(v) do
    acc
  end

  defp validate_search_params_mut_prob(_v, acc) do
    ["search_params_mut_prob invalid" | acc]
  end

  defp validate_output_sat_limit(v, acc) when is_integer(v) and v >= 0 do
    acc
  end

  defp validate_output_sat_limit(_v, acc) do
    ["output_sat_limit invalid" | acc]
  end

  defp validate_ro_signal([v], acc) when is_float(v) do
    acc
  end

  defp validate_ro_signal(_v, acc) do
    ["ro_signal invalid" | acc]
  end

  defp validate_fitness_stagnation(v, acc) when is_boolean(v) do
    acc
  end

  defp validate_fitness_stagnation(_v, acc) do
    ["fitness_stagnation invalid" | acc]
  end

  defp validate_population_mgr_efficiency(v, acc) when is_integer(v) and v >= 0 do
    acc
  end
  
  defp validate_population_mgr_efficiency(_v, acc)
    ["population_mgr_efficiency invalid" | acc]
  end

  defp validate_interactive_selection(v, acc) when is_boolean(v) do
    acc
  end

  defp validate_interactive_selection(_v, acc) do
    ["interactive_selection invalid" | acc]
  end

  defp validate_re_entry_probability(v, acc) when is_float(v) do
    acc
  end

  defp validate_re_entry_probability(_v, acc) do
    ["re_entry_probability invalid" | acc]
  end

  defp validate_shof_ratio(v, acc) when is_integer(v) and v >= 0 do
    acc
  end

  defp validate_shof_ratio(_v, acc) do
    ["shof_ratio invalid" | acc]
  end

  defp validate_selection_algorithm_efficiency(v, acc) when is_integer(v) and v >= 0 do
    acc
  end

  defp validate_selection_algorithm_efficiency(_v, acc) do
    ["selection_algorithm_efficiency invalid" | acc]
  end

end
