defmodule ApxrIoWeb.Projects.ExperimentControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    user1 = insert(:user)
    user2 = insert(:user)

    team1 = insert(:team)
    team2 = insert(:team)

    project1 = insert(:project, team_id: team1.id)
    project2 = insert(:project, team_id: team1.id)
    project3 = insert(:project, team_id: team2.id)
    project4 = insert(:project, team_id: team2.id)

    rel =
      insert(
        :release,
        project: project1,
        version: "0.0.1",
        meta: build(:release_metadata)
      )

    insert(
      :release,
      project: project1,
      version: "0.0.2",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project1,
      version: "0.0.3-dev",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project2,
      version: "1.0.0",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project3,
      version: "0.0.1",
      meta: build(:release_metadata)
    )

    insert(
      :release,
      project: project4,
      version: "0.0.1",
      meta: build(:release_metadata)
    )

    experiment =
      insert(
        :experiment,
        description: "SDQFQLSMDFLM",
        release: rel,
        meta:
          build(
            :experiment_metadata,
            identifier: "1536357583135391000",
            backup_flag: true,
            started: "{{2018,9,7},-576460748933985000}",
            stopped: "{{2018,9,8},-576460429400119000}",
            duration: 80_600_000,
            status: "completed",
            interruptions: [],
            init_constraints: [
              %{
                data: %{
                  agent_encoding_types: [:neural],
                  annealing_parameters: [0.5],
                  connection_architecture: :recurrent,
                  heredity_types: [:darwinian],
                  hof_distinguishers: [:tot_n],
                  morphology: :dtm_morphology,
                  mutation_operators: %{
                    mutate_weights: 1,
                    add_bias: 1,
                    remove_bias: 1,
                    mutate_af: 1,
                    add_outlink: 1,
                    add_inlink: 1,
                    add_neuron: 1,
                    outsplice: 1,
                    add_sensor: 1,
                    add_sensorlink: 1,
                    add_actuator: 1,
                    add_actuatorlink: 1,
                    mutate_plasticity_parameter: 1
                  },
                  neural_afs: [:tanh],
                  neural_aggr_fs: [:dot_product],
                  neural_pfns: [:hebbian],
                  objectives: [:main_fitness, :inverse_tot_n],
                  perturbation_ranges: [1.0],
                  population_evo_alg_f: :generational,
                  population_fitness_postprocessor_f: :size_proportional,
                  population_selection_f: :hof_competition,
                  specie_distinguishers: [:tot_n],
                  substrate_linkforms: [:l2l_feedforward],
                  substrate_plasticities: [:none],
                  tot_topological_mutations_fs: %{ncount_exponential: 0.5},
                  tuning_duration_f: %{wsize_proportional: 0.5},
                  tuning_selection_fs: [:dynamic_random]
                }
              }
            ],
            pm_parameters: %{
              data: %{
                evaluations_limit: 5000,
                fitness_goal: :inf,
                generation_limit: 100,
                init_specie_size: 5,
                op_modes: [:gt, :validation],
                polis_id: :mathema,
                population_id: :dtm,
                specie_size_limit: 20,
                survival_percentage: 0.5
              }
            },
            total_runs: 5
          )
      )

    insert(:team_user, user: user1, team: team1)

    %{
      project1: project1,
      project2: project2,
      project3: project3,
      project4: project4,
      release: rel,
      experiment: experiment,
      team1: team1,
      team2: team2,
      user1: user1,
      user2: user2
    }
  end

  describe "GET /projects/:name/experiments/all" do
    test "list experiments", %{user1: user1, project1: project1} do
      build_conn()
      |> test_login(user1)
      |> get("/projects/#{project1.name}/experiments/all")
      |> response(200)
    end

    test "dont list private experiments", %{user1: user1, project3: project3} do
      build_conn()
      |> test_login(user1)
      |> get("/projects/#{project3.name}/experiments/all")
      |> response(404)
    end
  end

  describe "GET /projects/:name/releases/:version/experiments/:id" do
    test "show experiment", %{
      user1: user1,
      project1: project1,
      release: release,
      experiment: experiment
    } do
      build_conn()
      |> test_login(user1)
      |> get(
        "/projects/#{project1.name}/releases/#{release.version}/experiments/#{experiment.id}"
      )
      |> response(200)
    end
  end
end
