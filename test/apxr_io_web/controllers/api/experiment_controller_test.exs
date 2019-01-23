defmodule ApxrIoWeb.API.ExperimentControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIo.Accounts.AuditLog
  alias ApxrIo.Learn.Experiment
  alias ApxrIo.Learn.Experiments

  setup do
    user = insert(:user)
    unauthorized_user = insert(:user)

    team = insert(:team)
    nbteam = insert(:team, billing_active: false)
    other_team = insert(:team)

    project = insert(:project, team: team)
    project2 = insert(:project, team: team)
    project3 = insert(:project, team: nbteam)
    project4 = insert(:project, team: other_team)

    release = insert(:release, project: project, version: "0.0.1")
    release2 = insert(:release, project: project, version: "0.0.2")
    release3 = insert(:release, project: project, version: "0.0.3")
    release4 = insert(:release, project: project3, version: "0.0.1")

    insert(:release, project: project2, version: "0.0.1")

    insert(:release,
      project: project4,
      version: "0.0.1",
      retirement: %{reason: "other", message: "not backward compatible"}
    )

    insert(:release, project: project4, version: "1.0.0")

    insert(:team_user, team: team, user: user)

    experiment =
      insert(
        :experiment,
        description: "SDQFQLSMDFLM",
        release: release,
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

    experiment2 = %{
      description: "SDQFQLSMDFLM",
      release_id: release2.id,
      meta: %{
        identifier: "153635758313243235391000",
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
      }
    }

    experiment3 = %{
      description: "SDQFQLSMDFLM",
      release_id: release3.id,
      meta: %{
        identifier: "1536357583134324243235391000",
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
      }
    }

    uexperiment = %{
      description: "SDQFQLSMDFLM",
      release_id: release3.id,
      meta: %{
        identifier: "1536357583134324243235391000",
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
      },
      trace_acc: [
        %{
          data: %{
            stats: [
              [
                %{
                  data: %{
                    avg_diversity: 1,
                    avg_fitness: [122.0000000000001],
                    avg_neurons: 2.0,
                    evaluations: 0,
                    max_fitness: [122.0000000000001],
                    min_fitness: [122.0000000000001],
                    morphology: :dtm_morphology,
                    specie_id: %{specie: 1.4371871231435058},
                    std_fitness: :inf,
                    std_neurons: 0.0,
                    time_stamp: -576_460_447_388_161_000,
                    validation_fitness: :void
                  }
                }
              ]
            ],
            step_size: 500,
            tot_evaluations: 9863.0
          }
        },
        %{
          data: %{
            stats: [
              [
                %{
                  data: %{
                    avg_diversity: 1,
                    avg_fitness: [111.60000000000014],
                    avg_neurons: 2.0,
                    evaluations: 0,
                    max_fitness: [111.60000000000014],
                    min_fitness: [111.60000000000014],
                    morphology: :dtm_morphology,
                    specie_id: %{specie: 1.8214531913639145},
                    std_fitness: :inf,
                    std_neurons: 0.0,
                    time_stamp: -576_460_500_880_041_000,
                    validation_fitness: :void
                  }
                }
              ]
            ],
            step_size: 500,
            tot_evaluations: 8410.0
          }
        },
        %{
          data: %{
            stats: [
              [
                %{
                  data: %{
                    avg_diversity: 1,
                    avg_fitness: [110.20000000000013],
                    avg_neurons: 1.0,
                    evaluations: 5946.0,
                    max_fitness: [110.20000000000013],
                    min_fitness: [110.20000000000013],
                    morphology: :dtm_morphology,
                    specie_id: %{specie: 4.343880044146821},
                    std_fitness: :inf,
                    std_neurons: 0.0,
                    time_stamp: -576_460_547_710_797_000,
                    validation_fitness: :void
                  }
                }
              ],
              [
                %{
                  data: %{
                    avg_diversity: 1,
                    avg_fitness: [118.80000000000011],
                    avg_neurons: 1.0,
                    evaluations: 3747.0,
                    max_fitness: [118.80000000000011],
                    min_fitness: [118.80000000000011],
                    morphology: :dtm_morphology,
                    specie_id: %{specie: 4.343880044146821},
                    std_fitness: :inf,
                    std_neurons: 0.0,
                    time_stamp: -576_460_579_658_012_000,
                    validation_fitness: %{
                      fitness: [110.80000000000014],
                      agent: 1.8626167383518626
                    }
                  }
                }
              ]
            ],
            step_size: 500,
            tot_evaluations: 9666.0
          }
        },
        %{
          data: %{
            stats: [
              [
                %{
                  data: %{
                    avg_diversity: 1,
                    avg_fitness: [122.0000000000001],
                    avg_neurons: 2.0,
                    evaluations: 0,
                    max_fitness: [122.0000000000001],
                    min_fitness: [122.0000000000001],
                    morphology: :dtm_morphology,
                    specie_id: %{specie: 2.4212499068997544},
                    std_fitness: :inf,
                    std_neurons: 0.0,
                    time_stamp: -576_460_600_560_254_000,
                    validation_fitness: :void
                  }
                }
              ],
              [
                %{
                  data: %{
                    avg_diversity: 1,
                    avg_fitness: [121.2000000000001],
                    avg_neurons: 2.0,
                    evaluations: 3907.0,
                    max_fitness: [121.2000000000001],
                    min_fitness: [121.2000000000001],
                    morphology: :dtm_morphology,
                    specie_id: %{specie: 2.4212499068997544},
                    std_fitness: :inf,
                    std_neurons: 0.0,
                    time_stamp: -576_460_634_053_245_000,
                    validation_fitness: %{fitness: [121.2000000000001], agent: 8.657592343491151}
                  }
                }
              ]
            ],
            step_size: 500,
            tot_evaluations: 9240.0
          }
        },
        %{
          data: %{
            stats: [
              [
                %{
                  data: %{
                    avg_diversity: 1,
                    avg_fitness: [111.80000000000014],
                    avg_neurons: 1.0,
                    evaluations: 0,
                    max_fitness: [111.80000000000014],
                    min_fitness: [111.80000000000014],
                    morphology: :dtm_morphology,
                    specie_id: %{specie: 7.283701082221204},
                    std_fitness: :inf,
                    std_neurons: 0.0,
                    time_stamp: -576_460_654_891_967_000,
                    validation_fitness: :void
                  }
                }
              ],
              [
                %{
                  data: %{
                    avg_diversity: 1,
                    avg_fitness: [112.40000000000013],
                    avg_neurons: 1.0,
                    evaluations: 3370.0,
                    max_fitness: [112.40000000000013],
                    min_fitness: [112.40000000000013],
                    morphology: :dtm_morphology,
                    specie_id: %{specie: 7.283701082221204},
                    std_fitness: :inf,
                    std_neurons: 0.0,
                    time_stamp: -576_460_677_736_102_000,
                    validation_fitness: %{fitness: [110.80000000000014], agent: 1.564879436189423}
                  }
                }
              ]
            ],
            step_size: 500,
            tot_evaluations: 7813.0
          }
        }
      ]
    }

    %{
      project: project,
      project2: project2,
      project3: project3,
      project4: project4,
      release: release,
      release2: release2,
      release3: release3,
      release4: release4,
      experiment: experiment,
      experiment2: experiment2,
      experiment3: experiment3,
      uexperiment: uexperiment,
      team: team,
      nbteam: nbteam,
      user: user,
      unauthorized_user: unauthorized_user
    }
  end

  describe "GET /api/repos/:repo/projects/:project/experiments/all" do
    test "show experiments in project", %{
      user: user,
      team: team,
      project: project
    } do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects/#{project.name}/experiments/all")
        |> json_response(200)

      assert length(result) == 1
    end

    test "show experiments in team authorizes", %{
      team: team,
      unauthorized_user: unauthorized_user,
      project: project
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects/#{project.name}/experiments/all")
      |> json_response(401)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> get("api/repos/#{team.name}/projects/#{project.name}/experiments/all")
      |> json_response(403)
    end
  end

  describe "GET /api/repos/:repo/projects/:project/releases/:version/experiments/:id" do
    test "get experiment unauthenticated", %{
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> get(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> json_response(401)
    end

    test "get project returns 404 for unknown team", %{
      user: user,
      project: project,
      release: release,
      experiment: experiment
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get(
        "api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> json_response(404)
    end

    test "get experiment returns 404 for unknown project if you are authorized", %{
      user: user,
      team: team,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get(
        "api/repos/#{team.name}/projects/UNKNOWN_PROJECT/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> json_response(404)
    end
  end

  describe "POST /api/repos/:repo/:project/releases/:version/experiments" do
    test "create experiment authorizes", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      experiment3: experiment3,
      release3: release3
    } do
      experiment_count = Experiments.count(project)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release3.version}/experiments",
        %{"experiment" => experiment3}
      )
      |> json_response(403)

      assert experiment_count == Experiments.count(project)
    end

    test "experiment requires write permission", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      experiment3: experiment3,
      release3: release3
    } do
      insert(:team_user, team: team, user: unauthorized_user, role: "read")

      experiment_count = Experiments.count(project)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release3.version}/experiments",
        %{"experiment" => experiment3}
      )
      |> json_response(403)

      assert experiment_count == Experiments.count(project)
    end

    test "team needs to have active billing", %{
      nbteam: nbteam,
      project3: project3,
      release4: release4,
      experiment3: experiment3
    } do
      user = insert(:user)

      insert(:team_user, team: nbteam, user: user, role: "write")

      experiment_count = Experiments.count(project3)

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{nbteam.name}/projects/#{project3.name}/releases/#{release4.version}/experiments",
        %{"experiment" => experiment3}
      )
      |> json_response(403)

      assert experiment_count == Experiments.count(project3)
    end

    test "create experiment", %{
      team: team,
      project: project,
      experiment2: experiment2,
      release2: release2
    } do
      Mox.stub(ApxrIo.Learn.Mock, :start, fn _proj, _v, experiment, _audit_data ->
        {:ok, %{experiment: experiment}}
      end)

      experiment_count = Experiments.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release2.version}/experiments",
        %{"experiment" => experiment2}
      )
      |> json_response(201)

      assert experiment_count + 1 == Experiments.count(project)

      log = ApxrIo.Repo.one!(AuditLog)
      assert log.user_id == user.id
      assert log.team_id == team.id
      assert log.action == "experiment.create"
      assert log.params["project"]["name"] == project.name
      assert log.params["release"]["version"] == "0.0.2"
    end
  end

  describe "POST /api/repos/:repo/projects/:project/releases/:version/experiments/:id" do
    test "update experiment authorizes", %{
      user: user,
      team: team,
      project: project,
      experiment: experiment,
      uexperiment: uexperiment,
      release: release
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }",
        %{"data" => uexperiment}
      )
      |> json_response(403)
    end

    test "update experiment", %{
      team: team,
      project: project,
      experiment: experiment,
      uexperiment: uexperiment,
      release: release
    } do
      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }",
        %{"data" => uexperiment}
      )
      |> json_response(201)
    end
  end

  describe "DELETE /api/repos/:repo/projects/:project/releases/:version/experiments/:id" do
    test "authorizes", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> delete(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> response(403)

      assert ApxrIo.Repo.get_by!(Experiment, id: experiment.id)
    end

    test "delete experiment", %{
      team: team,
      project: project,
      experiment: experiment,
      release: release
    } do
      Mox.stub(ApxrIo.Learn.Mock, :delete, fn _proj, _v, _eid, _audit_data ->
        :ok
      end)

      experiment_count = Experiments.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "admin")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete(
        "api/repos/#{team.name}/projects/#{project.name}/releases/#{release.version}/experiments/#{
          experiment.id
        }"
      )
      |> response(204)

      refute ApxrIo.Repo.get_by(Experiment, id: experiment.id)
      assert experiment_count - 1 == Experiments.count(project)

      [log] = ApxrIo.Repo.all(AuditLog)
      assert log.user_id == user.id
      assert log.action == "experiment.delete"
      assert log.params["project"]["name"] == project.name
      assert log.params["release"]["version"] == "0.0.1"
    end
  end
end
