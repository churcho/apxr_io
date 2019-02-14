defmodule ApxrIo.Learn.ExperimentMetadata do
  use ApxrIoWeb, :schema

  @params ~w(started completed duration progress total_runs run_index
  interruptions exp_parameters pm_parameters init_constraints)a

  embedded_schema do
    field :started, :binary
    field :completed, :binary
    field :duration, :integer
    field :progress, :string
    field :total_runs, :integer
    field :run_index, :integer
    field :interruptions, {:array, :any}
    field :exp_parameters, :map
    field :pm_parameters, :map
    field :init_constraints, {:array, :map}
  end

  def changeset(meta, params) do
    cast(meta, params, @params)
    |> validate_inclusion(:progress, ~w(paused, in_progress completed))
    |> validate_parameters(:exp_parameters)
    |> validate_parameters(:pm_parameters)
    |> validate_parameters(:init_constraints)
  end

  defp validate_parameters(changeset, field) do
    case changeset.valid? do
      true ->
        parameters = get_field(changeset, field)

        case parameters_validator(field, parameters) do
          [] ->
            changeset

          errors ->
            Enum.reduce(errors, changeset, fn e, acc ->
              add_error(acc, field, e)
            end)
        end

      _ ->
        changeset
    end
  end

  defp parameters_validator(field, parameters) when is_map(parameters) do
    case field do
      :exp_parameters ->
        exp_parameters_validator(parameters)

      :pm_parameters ->
        pm_parameters_validator(parameters)

      :init_constraints ->
        init_constraints_validator(parameters)
    end
  end

  defp parameters_validator(_field, _parameters) do
    []
  end

  defp exp_parameters_validator(parameters) do
    Enum.reduce(parameters, [], fn {k, v}, acc ->
      case k do
        "identifier" ->
          validate_identifier(v, acc)

        "public_scape" ->
          validate_public_scape(v, acc)

        "runs" ->
          validate_runs(v, acc)

        "min_pimprovement" ->
          validate_min_pimprovement(v, acc)

        "search_params_mut_prob" ->
          validate_search_params_mut_prob(v, acc)

        "output_sat_limit" ->
          validate_output_sat_limit(v, acc)

        "ro_signal" ->
          validate_ro_signal(v, acc)

        "fitness_stagnation" ->
          validate_fitness_stagnation(v, acc)

        "population_mgr_efficiency" ->
          validate_population_mgr_efficiency(v, acc)

        "interactive_selection" ->
          validate_interactive_selection(v, acc)

        "re_entry_probability" ->
          validate_re_entry_probability(v, acc)

        "shof_ratio" ->
          validate_shof_ratio(v, acc)

        "selection_algorithm_efficiency" ->
          validate_selection_algorithm_efficiency(v, acc)

        _ ->
          acc
      end
    end)
  end

  defp pm_parameters_validator(parameters) do
    Enum.reduce(parameters, [], fn {k, v}, acc ->
      case k do
        "op_modes" ->
          validate_op_modes(v, acc)

        "population_id" ->
          validate_population_id(v, acc)

        "polis_id" ->
          validate_polis_id(v, acc)

        "survival_percentage" ->
          validate_survival_percentage(v, acc)

        "init_specie_size" ->
          validate_init_specie_size(v, acc)

        "specie_size_limit" ->
          validate_specie_size_limit(v, acc)

        "generation_limit" ->
          validate_generation_limit(v, acc)

        "evaluations_limit" ->
          validate_evaluations_limit(v, acc)

        "fitness_goal" ->
          validate_fitness_goal(v, acc)

        _ ->
          acc
      end
    end)
  end

  defp init_constraints_validator(parameters) do
    Enum.reduce(parameters, [], fn {k, v}, acc ->
      case k do
        "morphology" ->
          validate_morphology(v, acc)

        "connection_architecture" ->
          validate_connection_architecture(v, acc)

        "agent_encoding_types" ->
          validate_agent_encoding_types(v, acc)

        "substrate_plasticities" ->
          validate_substrate_plasticities(v, acc)

        "substrate_linkforms" ->
          validate_substrate_linkforms(v, acc)

        "neural_afs" ->
          validate_neural_afs(v, acc)

        "neural_pfns" ->
          validate_neural_pfns(v, acc)

        "neural_aggr_fs" ->
          validate_neural_aggr_fs(v, acc)

        "tuning_selection_fs" ->
          validate_tuning_selection_fs(v, acc)

        "tuning_duration_f" ->
          validate_tuning_duration_f(v, acc)

        "annealing_parameters" ->
          validate_annealing_parameters(v, acc)

        "perturbation_ranges" ->
          validate_perturbation_ranges(v, acc)

        "heredity_types" ->
          validate_heredity_types(v, acc)

        "mutation_operators" ->
          validate_mutation_operators(v, acc)

        "tot_topological_mutations_fs" ->
          validate_tot_topological_mutations_fs(v, acc)

        "population_evo_alg_f" ->
          validate_population_evo_alg_f(v, acc)

        "population_selection_f" ->
          validate_population_selection_f(v, acc)

        "specie_distinguishers" ->
          validate_specie_distinguishers(v, acc)

        "hof_distinguishers" ->
          validate_hof_distinguishers(v, acc)

        _ ->
          acc
      end
    end)
  end

  # exp_parameters validators

  defp validate_identifier(v, acc) when v != "all" do
    acc
  end

  defp validate_identifier(_v, acc) do
    ["identifier invalid" | acc]
  end

  defp validate_public_scape(v, acc) when v == [] do
    acc
  end

  defp validate_public_scape(v, acc) when is_list(v) do
    case v do
      [x, y, w, h, scape] ->
        if is_float(x) && is_float(y) && is_float(w) && is_float(h) && is_atom(scape) do
          acc
        else
          ["public_scape invalid" | acc]
        end

      _ ->
        ["public_scape invalid" | acc]
    end
  end

  defp validate_public_scape(_v, acc) do
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

  defp validate_ro_signal(v, acc) when is_list(v) do
    result = Enum.filter(v, fn x -> is_float(x) end)

    case result do
      [] ->
        ["ro_signal invalid" | acc]

      _ ->
        acc
    end
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

  defp validate_population_mgr_efficiency(_v, acc) do
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

  # pm_parameters validators

  defp validate_op_modes(v, acc) when is_list(v) do
    result = Enum.filter(v, fn x -> x == "gt" or x == "validation" end)

    case result do
      [] ->
        ["op_modes invalid" | acc]

      _ ->
        acc
    end
  end

  defp validate_op_modes(_v, acc) do
    ["op_modes invalid" | acc]
  end

  defp validate_population_id(v, acc) when is_atom(v) do
    acc
  end

  defp validate_population_id(_v, acc) do
    ["population_id invalid" | acc]
  end

  defp validate_polis_id(v, acc) when is_atom(v) do
    acc
  end

  defp validate_polis_id(_v, acc) do
    ["polis_id invalid" | acc]
  end

  defp validate_survival_percentage(v, acc) when is_float(v) do
    acc
  end

  defp validate_survival_percentage(_v, acc) do
    ["survival_percentage invalid" | acc]
  end

  defp validate_init_specie_size(v, acc) when is_integer(v) and v > 0 do
    acc
  end

  defp validate_init_specie_size(_v, acc) do
    ["init_specie_size invalid" | acc]
  end

  defp validate_specie_size_limit(v, acc) when is_integer(v) and v > 0 do
    acc
  end

  defp validate_specie_size_limit(_v, acc) do
    ["specie_size_limit invalid" | acc]
  end

  defp validate_generation_limit(v, acc) when is_integer(v) and v > 0 do
    acc
  end

  defp validate_generation_limit(_v, acc) do
    ["generation_limit invalid" | acc]
  end

  defp validate_evaluations_limit(v, acc) when is_integer(v) and v > 0 do
    acc
  end

  defp validate_evaluations_limit(_v, acc) do
    ["evaluations_limit invalid" | acc]
  end

  defp validate_fitness_goal("inf", acc) do
    acc
  end

  defp validate_fitness_goal(v, acc) when is_integer(v) or is_float(v) do
    acc
  end

  defp validate_fitness_goal(_v, acc) do
    ["fitness_goal invalid" | acc]
  end

  # init_constraints validators

  defp validate_morphology(v, acc) when is_atom(v) do
    acc
  end

  defp validate_morphology(_v, acc) do
    ["morphology invalid" | acc]
  end

  defp validate_connection_architecture(v, acc) when is_list(v) do
    if v -- ["recurrent", "feedforward"] == [] do
      acc
    else
      ["connection_architecture invalid" | acc]
    end
  end

  defp validate_connection_architecture(_v, acc) do
    ["connection_architecture invalid" | acc]
  end

  defp validate_agent_encoding_types(v, acc) when is_list(v) do
    if v -- ["neural", "substrate"] == [] do
      acc
    else
      ["agent_encoding_types invalid" | acc]
    end
  end

  defp validate_agent_encoding_types(_v, acc) do
    ["agent_encoding_types invalid" | acc]
  end

  defp validate_substrate_plasticities(v, acc) when is_list(v) do
    if v -- ["none", "iterative", "abcn"] == [] do
      acc
    else
      ["substrate_plasticities invalid" | acc]
    end
  end

  defp validate_substrate_plasticities(_v, acc) do
    ["substrate_plasticities invalid" | acc]
  end

  defp validate_substrate_linkforms(v, acc) when is_list(v) do
    if v --
         [
           "l2l_feedforward",
           "jordan_recurrent",
           "fully_connected",
           "fully_interconnected",
           "neuronself_recurrent"
         ] == [] do
      acc
    else
      ["substrate_linkforms invalid" | acc]
    end
  end

  defp validate_substrate_linkforms(_v, acc) do
    ["substrate_linkforms invalid" | acc]
  end

  defp validate_neural_afs(v, acc) when is_list(v) do
    if v -- ["tanh", "relu", "cos", "gaussian", "absolute", "sin", "sqrt", "sigmoid"] == [] do
      acc
    else
      ["neural_afs invalid" | acc]
    end
  end

  defp validate_neural_afs(_v, acc) do
    ["neural_afs invalid" | acc]
  end

  defp validate_neural_pfns(v, acc) when is_list(v) do
    if v --
         [
           "none",
           "hebbian_w",
           "hebbian",
           "ojas_w",
           "ojas",
           "self_modulation_v1",
           "self_modulation_v2",
           "self_modulation_v2",
           "self_modulation_v3",
           "self_modulation_v4",
           "self_modulation_v5",
           "self_modulation_v6",
           "neuromodulation"
         ] == [] do
      acc
    else
      ["neural_pfns invalid" | acc]
    end
  end

  defp validate_neural_pfns(_v, acc) do
    ["neural_pfns invalid" | acc]
  end

  defp validate_neural_aggr_fs(v, acc) when is_list(v) do
    if v -- ["dot_product", "diff_product", "mult_product"] == [] do
      acc
    else
      ["neural_aggr_fs invalid" | acc]
    end
  end

  defp validate_neural_aggr_fs(_v, acc) do
    ["neural_aggr_fs invalid" | acc]
  end

  defp validate_tuning_selection_fs(v, acc) when is_list(v) do
    if v --
         [
           "all",
           "all_random",
           "dynamic",
           "dynamic_random",
           "active",
           "active_random",
           "current",
           "current_random"
         ] == [] do
      acc
    else
      ["tuning_selection_fs invalid" | acc]
    end
  end

  defp validate_tuning_selection_fs(_v, acc) do
    ["tuning_selection_fs invalid" | acc]
  end

  defp validate_tuning_duration_f({func, param}, acc)
       when func in ["wsize_proportional", "nsize_proportional", "const"] and is_float(param) do
    acc
  end

  defp validate_tuning_duration_f(_v, acc) do
    ["tuning_duration_f invalid" | acc]
  end

  defp validate_annealing_parameters(v, acc) when is_list(v) do
    result = Enum.filter(v, fn x -> is_float(x) end)

    case result do
      [] ->
        ["annealing_parameters invalid" | acc]

      _ ->
        acc
    end
  end

  defp validate_annealing_parameters(_v, acc) do
    ["annealing_parameters invalid" | acc]
  end

  defp validate_perturbation_ranges(v, acc) when is_list(v) do
    result = Enum.filter(v, fn x -> is_float(x) end)

    case result do
      [] ->
        ["perturbation_ranges invalid" | acc]

      _ ->
        acc
    end
  end

  defp validate_perturbation_ranges(_v, acc) do
    ["perturbation_ranges invalid" | acc]
  end

  defp validate_heredity_types(v, acc) when is_list(v) do
    result = Enum.filter(v, fn x -> x == "darwinian" or x == "lamarckian" end)

    case result do
      [] ->
        ["op_modes invalid" | acc]

      _ ->
        acc
    end
  end

  defp validate_heredity_types(_v, acc) do
    ["heredity_types invalid" | acc]
  end

  defp validate_mutation_operators(ops, acc) when is_list(ops) do
    mutation_operators = [
      "mutate_weights",
      "add_bias",
      "remove_bias",
      "mutate_af",
      "add_outlink",
      "add_inlink",
      "add_neuron",
      "outsplice",
      "add_sensor",
      "add_actuator",
      "add_sensorlink",
      "add_actuatorlink",
      "mutate_plasticity_parameters",
      "add_cpp",
      "add_cep"
    ]

    Enum.reduce(ops, acc, fn {k, v}, acc1 ->
      if k in mutation_operators and is_integer(v) do
        acc1
      else
        ["mutation_operator #{k} invalid" | acc1]
      end
    end)
  end

  defp validate_mutation_operators(_v, acc) do
    ["mutation_operators invalid" | acc]
  end

  defp validate_tot_topological_mutations_fs({func, param}, acc)
       when func in ["ncount_exponential", "ncount_linear"] and is_float(param) do
    acc
  end

  defp validate_tot_topological_mutations_fs(_v, acc) do
    ["tot_topological_mutations_fs invalid" | acc]
  end

  defp validate_population_evo_alg_f(v, acc) when v == "generational" or v == "steady_state" do
    acc
  end

  defp validate_population_evo_alg_f(_v, acc) do
    ["population_evo_alg_f invalid" | acc]
  end

  defp validate_population_selection_f(v, acc)
       when v in ["hof_competition", "hof_rank", "hof_top3", "hof_efficiency", "hof_random"] do
    acc
  end

  defp validate_population_selection_f(_v, acc) do
    ["population_selection_f invalid" | acc]
  end

  defp validate_specie_distinguishers(v, acc) when is_list(v) do
    if v --
         [
           "tot_n",
           "tot_inlinks",
           "tot_outlinks",
           "tot_sensors",
           "tot_actuators",
           "pattern",
           "tot_tanh",
           "tot_sin",
           "tot_cos",
           "tot_gaus",
           "tot_lin"
         ] == [] do
      acc
    else
      ["specie_distinguishers invalid" | acc]
    end
  end

  defp validate_specie_distinguishers(_v, acc) do
    ["specie_distinguishers invalid" | acc]
  end

  defp validate_hof_distinguishers(v, acc) when is_list(v) do
    if v --
         [
           "tot_n",
           "tot_inlinks",
           "tot_outlinks",
           "tot_sensors",
           "tot_actuators",
           "pattern",
           "tot_tanh",
           "tot_sin",
           "tot_cos",
           "tot_gaus",
           "tot_lin"
         ] == [] do
      acc
    else
      ["hof_distinguishers invalid" | acc]
    end
  end

  defp validate_hof_distinguishers(_v, acc) do
    ["hof_distinguishers invalid" | acc]
  end
end
