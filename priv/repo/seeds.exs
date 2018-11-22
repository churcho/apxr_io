import ApxrIo.Factory

ApxrIo.Fake.start()

lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
  tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."

ApxrIo.Repo.transaction(fn ->
  myrepo = insert(:team, name: "myrepo")

  eric_email = "eric@example.com"
  jose_email = "jose@example.com"
  joe_email = "joe@example.com"

  eric =
    insert(
      :user,
      username: "eric",
      emails: [build(:email, email: eric_email, email_hash: eric_email)]
    )

  jose =
    insert(
      :user,
      username: "jose",
      emails: [build(:email, email: jose_email, email_hash: jose_email)]
    )

  joe =
    insert(
      :user,
      username: "joe",
      emails: [build(:email, email: joe_email, email_hash: joe_email)]
    )

  insert(:team_user, team: myrepo, user: eric, role: "admin")
  insert(:team_user, team: myrepo, user: jose, role: "write")
  insert(:team_user, team: myrepo, user: joe, role: "write")

  decimal =
    insert(
      :project,
      team_id: myrepo.id,
      project_owners: [build(:project_owner, user: eric)],
      meta:
        build(
          :project_metadata,
          licenses: ["Apache 2.0", "MIT"],
          links: %{"Github" => "http://example.com/github"},
          description: "Arbitrary precision decimal arithmetic for Elixir"
        )
    )

  insert(
    :release,
    project: decimal,
    version: "0.0.1",
    meta:
      build(
        :release_metadata,
        build_tool: "python",
        build_tool_version: 3.0
      )
  )

  insert(
    :release,
    project: decimal,
    version: "0.0.2",
    meta:
      build(
        :release_metadata,
        build_tool: "python",
        build_tool_version: 3.0
      )
  )

  insert(
    :release,
    project: decimal,
    version: "0.1.0",
    meta:
      build(
        :release_metadata,
        build_tool: "python",
        build_tool_version: 3.0
      )
  )

  postgrex =
    insert(
      :project,
      team_id: myrepo.id,
      name: "postgrex",
      project_owners: [build(:project_owner, user: eric), build(:project_owner, user: jose)],
      meta:
        build(
          :project_metadata,
          licenses: ["Apache 2.0"],
          links: %{"Github" => "http://example.com/github"},
          description: lorem
        )
    )

  insert(
    :release,
    project: postgrex,
    version: "0.0.1",
    meta:
      build(
        :release_metadata,
        build_tool: "python"
      )
  )

  insert(
    :release,
    project: postgrex,
    version: "0.0.2",
    meta:
      build(
        :release_metadata,
        build_tool: "python"
      )
  )

  insert(
    :release,
    project: postgrex,
    version: "0.1.0",
    meta:
      build(
        :release_metadata,
        build_tool: "elixir"
      )
  )

  ecto =
    insert(
      :project,
      team_id: myrepo.id,
      name: "ecto",
      project_owners: [build(:project_owner, user: jose)],
      meta:
        build(
          :project_metadata,
          licenses: [],
          links: %{"Github" => "http://example.com/github"},
          description: lorem
        )
    )

  insert(
    :release,
    project: ecto,
    version: "0.0.1",
    meta:
      build(
        :release_metadata,
        build_tool: "elixir"
      )
  )

  insert(
    :release,
    project: ecto,
    version: "0.0.2",
    meta:
      build(
        :release_metadata,
        build_tool: "elixir"
      )
  )

  ecto_rel4 =
    insert(
      :release,
      project: ecto,
      version: "0.1.0",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  ecto_rel3 =
    insert(
      :release,
      project: ecto,
      version: "0.1.1",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  ecto_rel2 =
    insert(
      :release,
      project: ecto,
      version: "0.1.2",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  ecto_rel1 =
    insert(
      :release,
      project: ecto,
      version: "0.1.3",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  ecto_rel =
    insert(
      :release,
      project: ecto,
      version: "0.2.0",
      meta:
        build(
          :release_metadata,
          build_tool: "elixir"
        )
    )

  private =
    insert(
      :project,
      team_id: myrepo.id,
      name: "private",
      project_owners: [build(:project_owner, user: eric)],
      meta:
        build(
          :project_metadata,
          licenses: [],
          links: %{"Github" => "http://example.com/github"},
          description: lorem
        )
    )

  insert(
    :release,
    project: private,
    version: "0.0.1",
    meta:
      build(
        :release_metadata,
        build_tool: "elixir"
      )
  )

  ecto_exp =
    insert(
      :experiment,
      description: lorem,
      release: ecto_rel,
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
        ),
      trace:
        build(
          :experiment_trace,
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5787.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_448_175_023_000,
                        validation_fitness: %{
                          fitness: [118.00000000000011],
                          agent: 1.3570186341785193
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 2.0,
                        evaluations: 4452.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_501_715_080_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 1.229791395419694
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
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
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5417.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 2.4212499068997544},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_601_514_361_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 2.3645207756533715
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        avg_fitness: [111.80000000000014],
                        avg_neurons: 1.0,
                        evaluations: 4474.0,
                        max_fitness: [111.80000000000014],
                        min_fitness: [111.80000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 7.283701082221204},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_655_730_126_000,
                        validation_fitness: %{
                          fitness: [111.80000000000014],
                          agent: 1.500341954669379
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
                      }
                    }
                  ]
                ],
                step_size: 500,
                tot_evaluations: 7813.0
              }
            }
          ]
        ),
      graph:
        build(
          :experiment_graph_data,
          fitness_vs_evals: %{
            morphology: "dtm_morphology",
            max_fitness: [122.0000000000001, 122.0000000000001],
            maxavg_fitness: [117.24000000000012, 115.52000000000012],
            min_fintess: [122.0000000000001, 122.0000000000001]
          },
          val_fitness_vs_evals: %{
            morphology: "dtm_morphology",
            validationmax_fitness: [122.0000000000001, 122.0000000000001],
            validationmin_fitness: [117.24000000000012, 115.52000000000012]
          },
          specie_pop_turnover_vs_evals: %{
            morphology: "dtm_morphology",
            specie_pop_turnover: [4775.4, 1189.2]
          },
          avg_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_val_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_neurons_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [500, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356],
              [1000, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356]
            ],
            avgs: [[500, 1.6], [1000, 1.6]]
          },
          avg_diversity_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [[500, 1.0 - 0.0, 1.0 + 0.0], [1000, 1.0 - 0.0, 1.0 + 0.0]],
            avgs: [[500, 1.0], [1000, 1.0]]
          }
        )
    )

  ecto_exp1 =
    insert(
      :experiment,
      description: lorem,
      release: ecto_rel1,
      meta:
        build(
          :experiment_metadata,
          identifier: "1536357583135391000",
          backup_flag: true,
          started: "{{2018,9,7},-576460748933985000}",
          stopped: "{{2018,9,8},-576460429400119000}",
          duration: 8_060_000_000,
          status: "in_progress",
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
          total_runs: 2
        ),
      trace:
        build(
          :experiment_trace,
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5787.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_448_175_023_000,
                        validation_fitness: %{
                          fitness: [118.00000000000011],
                          agent: 1.3570186341785193
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 2.0,
                        evaluations: 4452.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_501_715_080_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 1.229791395419694
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
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
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5417.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 2.4212499068997544},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_601_514_361_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 2.3645207756533715
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        avg_fitness: [111.80000000000014],
                        avg_neurons: 1.0,
                        evaluations: 4474.0,
                        max_fitness: [111.80000000000014],
                        min_fitness: [111.80000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 7.283701082221204},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_655_730_126_000,
                        validation_fitness: %{
                          fitness: [111.80000000000014],
                          agent: 1.500341954669379
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
                      }
                    }
                  ]
                ],
                step_size: 500,
                tot_evaluations: 7813.0
              }
            }
          ]
        ),
      graph:
        build(
          :experiment_graph_data,
          fitness_vs_evals: %{
            morphology: "dtm_morphology",
            max_fitness: [122.0000000000001, 122.0000000000001],
            maxavg_fitness: [117.24000000000012, 115.52000000000012],
            min_fintess: [122.0000000000001, 122.0000000000001]
          },
          val_fitness_vs_evals: %{
            morphology: "dtm_morphology",
            validationmax_fitness: [122.0000000000001, 122.0000000000001],
            validationmin_fitness: [117.24000000000012, 115.52000000000012]
          },
          specie_pop_turnover_vs_evals: %{
            morphology: "dtm_morphology",
            specie_pop_turnover: [4775.4, 1189.2]
          },
          avg_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_val_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_neurons_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [500, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356],
              [1000, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356]
            ],
            avgs: [[500, 1.6], [1000, 1.6]]
          },
          avg_diversity_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [[500, 1.0 - 0.0, 1.0 + 0.0], [1000, 1.0 - 0.0, 1.0 + 0.0]],
            avgs: [[500, 1.0], [1000, 1.0]]
          }
        )
    )

  ecto_exp2 =
    insert(
      :experiment,
      description: lorem,
      release: ecto_rel2,
      meta:
        build(
          :experiment_metadata,
          identifier: "1536357583135391000",
          backup_flag: true,
          started: "{{2018,9,7},-576460748933985000}",
          stopped: "{{2018,9,8},-576460429400119000}",
          duration: 8_060_000_000,
          status: "waiting",
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
          total_runs: 2
        ),
      trace:
        build(
          :experiment_trace,
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5787.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_448_175_023_000,
                        validation_fitness: %{
                          fitness: [118.00000000000011],
                          agent: 1.3570186341785193
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 2.0,
                        evaluations: 4452.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_501_715_080_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 1.229791395419694
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
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
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5417.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 2.4212499068997544},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_601_514_361_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 2.3645207756533715
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        avg_fitness: [111.80000000000014],
                        avg_neurons: 1.0,
                        evaluations: 4474.0,
                        max_fitness: [111.80000000000014],
                        min_fitness: [111.80000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 7.283701082221204},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_655_730_126_000,
                        validation_fitness: %{
                          fitness: [111.80000000000014],
                          agent: 1.500341954669379
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
                      }
                    }
                  ]
                ],
                step_size: 500,
                tot_evaluations: 7813.0
              }
            }
          ]
        ),
      graph:
        build(
          :experiment_graph_data,
          fitness_vs_evals: %{
            morphology: "dtm_morphology",
            max_fitness: [122.0000000000001, 122.0000000000001],
            maxavg_fitness: [117.24000000000012, 115.52000000000012],
            min_fintess: [122.0000000000001, 122.0000000000001]
          },
          val_fitness_vs_evals: %{
            morphology: "dtm_morphology",
            validationmax_fitness: [122.0000000000001, 122.0000000000001],
            validationmin_fitness: [117.24000000000012, 115.52000000000012]
          },
          specie_pop_turnover_vs_evals: %{
            morphology: "dtm_morphology",
            specie_pop_turnover: [4775.4, 1189.2]
          },
          avg_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_val_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_neurons_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [500, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356],
              [1000, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356]
            ],
            avgs: [[500, 1.6], [1000, 1.6]]
          },
          avg_diversity_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [[500, 1.0 - 0.0, 1.0 + 0.0], [1000, 1.0 - 0.0, 1.0 + 0.0]],
            avgs: [[500, 1.0], [1000, 1.0]]
          }
        )
    )

  ecto_exp3 =
    insert(
      :experiment,
      description: lorem,
      release: ecto_rel3,
      meta:
        build(
          :experiment_metadata,
          identifier: "1536357583135391000",
          backup_flag: true,
          started: "{{2018,9,7},-576460748933985000}",
          stopped: "{{2018,9,8},-576460429400119000}",
          duration: 8_060_000_000,
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
          total_runs: 2
        ),
      trace:
        build(
          :experiment_trace,
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5787.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_448_175_023_000,
                        validation_fitness: %{
                          fitness: [118.00000000000011],
                          agent: 1.3570186341785193
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 2.0,
                        evaluations: 4452.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_501_715_080_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 1.229791395419694
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
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
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5417.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 2.4212499068997544},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_601_514_361_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 2.3645207756533715
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        avg_fitness: [111.80000000000014],
                        avg_neurons: 1.0,
                        evaluations: 4474.0,
                        max_fitness: [111.80000000000014],
                        min_fitness: [111.80000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 7.283701082221204},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_655_730_126_000,
                        validation_fitness: %{
                          fitness: [111.80000000000014],
                          agent: 1.500341954669379
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
                      }
                    }
                  ]
                ],
                step_size: 500,
                tot_evaluations: 7813.0
              }
            }
          ]
        ),
      graph:
        build(
          :experiment_graph_data,
          fitness_vs_evals: %{
            morphology: "dtm_morphology",
            max_fitness: [122.0000000000001, 122.0000000000001],
            maxavg_fitness: [117.24000000000012, 115.52000000000012],
            min_fintess: [122.0000000000001, 122.0000000000001]
          },
          val_fitness_vs_evals: %{
            morphology: "dtm_morphology",
            validationmax_fitness: [122.0000000000001, 122.0000000000001],
            validationmin_fitness: [117.24000000000012, 115.52000000000012]
          },
          specie_pop_turnover_vs_evals: %{
            morphology: "dtm_morphology",
            specie_pop_turnover: [4775.4, 1189.2]
          },
          avg_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_val_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_neurons_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [500, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356],
              [1000, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356]
            ],
            avgs: [[500, 1.6], [1000, 1.6]]
          },
          avg_diversity_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [[500, 1.0 - 0.0, 1.0 + 0.0], [1000, 1.0 - 0.0, 1.0 + 0.0]],
            avgs: [[500, 1.0], [1000, 1.0]]
          }
        )
    )

  ecto_exp4 =
    insert(
      :experiment,
      release: ecto_rel4,
      meta:
        build(
          :experiment_metadata,
          identifier: "1536357583135391000",
          backup_flag: true,
          started: "{{2018,9,7},-576460748933985000}",
          stopped: "{{2018,9,8},-576460429400119000}",
          duration: 8_060_000_000,
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
          total_runs: 2
        ),
      trace:
        build(
          :experiment_trace,
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5787.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_448_175_023_000,
                        validation_fitness: %{
                          fitness: [118.00000000000011],
                          agent: 1.3570186341785193
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 4091.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.4371871231435058},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_478_580_102_000,
                        validation_fitness: %{
                          fitness: [105.20000000000016],
                          agent: 36.29493258331371
                        }
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
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 2.0,
                        evaluations: 4452.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_501_715_080_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 1.229791395419694
                        }
                      }
                    },
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
                      }
                    }
                  ],
                  [
                    %{
                      data: %{
                        avg_diversity: 1,
                        avg_fitness: [111.60000000000014],
                        avg_neurons: 1.0,
                        evaluations: 3987.0,
                        max_fitness: [111.60000000000014],
                        min_fitness: [111.60000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 1.8214531913639145},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_525_941_047_000,
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.3343012802318095
                        }
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
                        avg_fitness: [122.0000000000001],
                        avg_neurons: 2.0,
                        evaluations: 5417.0,
                        max_fitness: [122.0000000000001],
                        min_fitness: [122.0000000000001],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 2.4212499068997544},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_601_514_361_000,
                        validation_fitness: %{
                          fitness: [111.60000000000014],
                          agent: 2.3645207756533715
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        validation_fitness: %{
                          fitness: [121.2000000000001],
                          agent: 8.657592343491151
                        }
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
                        avg_fitness: [111.80000000000014],
                        avg_neurons: 1.0,
                        evaluations: 4474.0,
                        max_fitness: [111.80000000000014],
                        min_fitness: [111.80000000000014],
                        morphology: :dtm_morphology,
                        specie_id: %{specie: 7.283701082221204},
                        std_fitness: :inf,
                        std_neurons: 0.0,
                        time_stamp: -576_460_655_730_126_000,
                        validation_fitness: %{
                          fitness: [111.80000000000014],
                          agent: 1.500341954669379
                        }
                      }
                    },
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
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
                        validation_fitness: %{
                          fitness: [110.80000000000014],
                          agent: 1.564879436189423
                        }
                      }
                    }
                  ]
                ],
                step_size: 500,
                tot_evaluations: 7813.0
              }
            }
          ]
        ),
      graph:
        build(
          :experiment_graph_data,
          fitness_vs_evals: %{
            morphology: "dtm_morphology",
            max_fitness: [122.0000000000001, 122.0000000000001],
            maxavg_fitness: [117.24000000000012, 115.52000000000012],
            min_fintess: [122.0000000000001, 122.0000000000001]
          },
          val_fitness_vs_evals: %{
            morphology: "dtm_morphology",
            validationmax_fitness: [122.0000000000001, 122.0000000000001],
            validationmin_fitness: [117.24000000000012, 115.52000000000012]
          },
          specie_pop_turnover_vs_evals: %{
            morphology: "dtm_morphology",
            specie_pop_turnover: [4775.4, 1189.2]
          },
          avg_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_val_fitness_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [
                500,
                117.24000000000012 - 4.672301360143611,
                117.24000000000012 + 4.672301360143611
              ],
              [
                1000,
                115.52000000000012 - 5.319548853051339,
                115.52000000000012 + 5.319548853051339
              ]
            ],
            avgs: [[500, 117.24000000000012], [1000, 115.52000000000012]]
          },
          avg_neurons_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [
              [500, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356],
              [1000, 1.6 - 0.4898979485566356, 1.6 + 0.4898979485566356]
            ],
            avgs: [[500, 1.6], [1000, 1.6]]
          },
          avg_diversity_vs_evals_std: %{
            morphology: "dtm_morphology",
            std: [[500, 1.0 - 0.0, 1.0 + 0.0], [1000, 1.0 - 0.0, 1.0 + 0.0]],
            avgs: [[500, 1.0], [1000, 1.0]]
          }
        )
    )

  insert(
    :artifact,
    experiment: ecto_exp,
    project: ecto,
    name: "ecto_arto",
    status: "offline",
    meta:
      build(
        :artifact_metadata,
        location: "Paris",
        scale_min: 1,
        scale_max: 10,
        scale_factor: 2
      ),
    stats:
      build(
        :artifact_stats,
        invocation_rate: [
          [1_167_609_600_000, 7537],
          [1_167_696_000_000, 7537],
          [1_167_782_400_000, 7559],
          [1_167_868_800_000, 7631],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 7757],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 767],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 7706],
          [1_169_769_600_000, 7752],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 7701],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 768],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 7613],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 7608],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 757],
          [1_172_707_200_000, 7562],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7645],
          [1_173_139_200_000, 7635],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 7604],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 7602],
          [1_173_744_000_000, 7566],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 7562],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 7518],
          [1_174_348_800_000, 7522],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 7491],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        replica_scaling: [
          [1_167_609_600_000, 753],
          [1_167_696_000_000, 753],
          [1_167_782_400_000, 759],
          [1_167_868_800_000, 731],
          [1_167_955_200_000, 744],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 777],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 76],
          [1_169_769_600_000, 52],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 771],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 13],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 78],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 75],
          [1_172_707_200_000, 762],
          [1_172_793_600_000, 75983],
          [1_173_052_800_000, 645],
          [1_173_139_200_000, 735],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 604],
          [1_173_398_400_000, 76033],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 75],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 752],
          [1_174_003_200_000, 72506],
          [1_174_262_400_000, 718],
          [1_174_348_800_000, 752],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 749],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        execution_duration: [
          [1_167_609_600_000, 37],
          [1_167_696_000_000, 75347],
          [1_167_782_400_000, 9559],
          [1_167_868_800_000, 31],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 79],
          [1_168_300_800_000, 76833],
          [1_168_387_200_000, 7],
          [1_168_473_600_000, 77],
          [1_168_560_000_000, 775],
          [1_168_819_200_000, 77284],
          [1_168_905_600_000, 77221],
          [1_168_992_000_000, 48],
          [1_169_078_400_000, 77],
          [1_169_164_800_000, 77185],
          [1_169_424_000_000, 77313],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 69],
          [1_169_683_200_000, 77],
          [1_169_769_600_000, 77523],
          [1_170_028_800_000, 7],
          [1_170_115_200_000, 7],
          [1_170_201_600_000, 721],
          [1_170_288_000_000, 81],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 773],
          [1_170_720_000_000, 7],
          [1_170_806_400_000, 701],
          [1_170_892_800_000, 76990],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 771],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 345],
          [1_171_497_600_000, 76130],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 76106],
          [1_171_929_600_000, 608],
          [1_172_016_000_000, 008],
          [1_172_102_400_000, 763],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 7],
          [1_172_534_400_000, 56],
          [1_172_620_800_000, 257],
          [1_172_707_200_000, 75362],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7],
          [1_173_139_200_000, 35],
          [1_173_225_600_000, 714],
          [1_173_312_000_000, 74],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 66],
          [1_173_830_400_000, 757],
          [1_173_916_800_000, 75],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 14],
          [1_174_348_800_000, 722],
          [1_174_435_200_000, 754],
          [1_174_521_600_000, 74],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 744],
          [1_174_953_600_000, 7343]
        ]
      )
  )

  insert(
    :artifact,
    experiment: ecto_exp1,
    project: ecto,
    name: "ecto_arto1",
    status: "online",
    meta:
      build(
        :artifact_metadata,
        location: "Paris",
        scale_min: 1,
        scale_max: 10,
        scale_factor: 2
      ),
    stats:
      build(
        :artifact_stats,
        invocation_rate: [
          [1_167_609_600_000, 7537],
          [1_167_696_000_000, 7537],
          [1_167_782_400_000, 7559],
          [1_167_868_800_000, 7631],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 7757],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 767],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 7706],
          [1_169_769_600_000, 7752],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 7701],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 768],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 7613],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 7608],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 757],
          [1_172_707_200_000, 7562],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7645],
          [1_173_139_200_000, 7635],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 7604],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 7602],
          [1_173_744_000_000, 7566],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 7562],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 7518],
          [1_174_348_800_000, 7522],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 7491],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        replica_scaling: [
          [1_167_609_600_000, 753],
          [1_167_696_000_000, 753],
          [1_167_782_400_000, 759],
          [1_167_868_800_000, 731],
          [1_167_955_200_000, 744],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 777],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 76],
          [1_169_769_600_000, 52],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 771],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 13],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 78],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 75],
          [1_172_707_200_000, 762],
          [1_172_793_600_000, 75983],
          [1_173_052_800_000, 645],
          [1_173_139_200_000, 735],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 604],
          [1_173_398_400_000, 76033],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 75],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 752],
          [1_174_003_200_000, 72506],
          [1_174_262_400_000, 718],
          [1_174_348_800_000, 752],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 749],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        execution_duration: [
          [1_167_609_600_000, 37],
          [1_167_696_000_000, 75347],
          [1_167_782_400_000, 9559],
          [1_167_868_800_000, 31],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 79],
          [1_168_300_800_000, 76833],
          [1_168_387_200_000, 7],
          [1_168_473_600_000, 77],
          [1_168_560_000_000, 775],
          [1_168_819_200_000, 77284],
          [1_168_905_600_000, 77221],
          [1_168_992_000_000, 48],
          [1_169_078_400_000, 77],
          [1_169_164_800_000, 77185],
          [1_169_424_000_000, 77313],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 69],
          [1_169_683_200_000, 77],
          [1_169_769_600_000, 77523],
          [1_170_028_800_000, 7],
          [1_170_115_200_000, 7],
          [1_170_201_600_000, 721],
          [1_170_288_000_000, 81],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 773],
          [1_170_720_000_000, 7],
          [1_170_806_400_000, 701],
          [1_170_892_800_000, 76990],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 345],
          [1_171_497_600_000, 76130],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 76106],
          [1_171_929_600_000, 608],
          [1_172_016_000_000, 008],
          [1_172_102_400_000, 76313],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 7],
          [1_172_534_400_000, 56],
          [1_172_620_800_000, 257],
          [1_172_707_200_000, 75362],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7],
          [1_173_139_200_000, 35],
          [1_173_225_600_000, 714],
          [1_173_312_000_000, 74],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 66],
          [1_173_830_400_000, 757],
          [1_173_916_800_000, 75],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 14],
          [1_174_348_800_000, 722],
          [1_174_435_200_000, 754],
          [1_174_521_600_000, 74],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 744],
          [1_174_953_600_000, 7343]
        ]
      )
  )

  insert(
    :artifact,
    experiment: ecto_exp2,
    project: ecto,
    name: "ecto_arto2",
    status: "online",
    meta:
      build(
        :artifact_metadata,
        location: "Paris",
        scale_min: 1,
        scale_max: 10,
        scale_factor: 2
      ),
    stats:
      build(
        :artifact_stats,
        invocation_rate: [
          [1_167_609_600_000, 7537],
          [1_167_696_000_000, 7537],
          [1_167_782_400_000, 7559],
          [1_167_868_800_000, 7631],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 7757],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 767],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 7706],
          [1_169_769_600_000, 7752],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 7701],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 768],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 7613],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 7608],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 757],
          [1_172_707_200_000, 7562],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7645],
          [1_173_139_200_000, 7635],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 7604],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 7602],
          [1_173_744_000_000, 7566],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 7562],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 7518],
          [1_174_348_800_000, 7522],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 7491],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        replica_scaling: [
          [1_167_609_600_000, 753],
          [1_167_696_000_000, 753],
          [1_167_782_400_000, 759],
          [1_167_868_800_000, 731],
          [1_167_955_200_000, 744],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 777],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 76],
          [1_169_769_600_000, 52],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 771],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 13],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 78],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 75],
          [1_172_707_200_000, 762],
          [1_172_793_600_000, 75983],
          [1_173_052_800_000, 645],
          [1_173_139_200_000, 735],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 604],
          [1_173_398_400_000, 76033],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 75],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 752],
          [1_174_003_200_000, 72506],
          [1_174_262_400_000, 718],
          [1_174_348_800_000, 752],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 749],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        execution_duration: [
          [1_167_609_600_000, 37],
          [1_167_696_000_000, 75347],
          [1_167_782_400_000, 9559],
          [1_167_868_800_000, 31],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 79],
          [1_168_300_800_000, 76833],
          [1_168_387_200_000, 7],
          [1_168_473_600_000, 77],
          [1_168_560_000_000, 775],
          [1_168_819_200_000, 77284],
          [1_168_905_600_000, 77221],
          [1_168_992_000_000, 48],
          [1_169_078_400_000, 77],
          [1_169_164_800_000, 77185],
          [1_169_424_000_000, 77313],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 69],
          [1_169_683_200_000, 77],
          [1_169_769_600_000, 77523],
          [1_170_028_800_000, 7],
          [1_170_115_200_000, 7],
          [1_170_201_600_000, 721],
          [1_170_288_000_000, 81],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 773],
          [1_170_720_000_000, 7],
          [1_170_806_400_000, 701],
          [1_170_892_800_000, 76990],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 345],
          [1_171_497_600_000, 76130],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 76106],
          [1_171_929_600_000, 608],
          [1_172_016_000_000, 008],
          [1_172_102_400_000, 76313],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 7],
          [1_172_534_400_000, 56],
          [1_172_620_800_000, 257],
          [1_172_707_200_000, 75362],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7],
          [1_173_139_200_000, 35],
          [1_173_225_600_000, 714],
          [1_173_312_000_000, 74],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 66],
          [1_173_830_400_000, 757],
          [1_173_916_800_000, 75],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 14],
          [1_174_348_800_000, 722],
          [1_174_435_200_000, 754],
          [1_174_521_600_000, 74],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 744],
          [1_174_953_600_000, 7343]
        ]
      )
  )

  insert(
    :artifact,
    experiment: ecto_exp3,
    project: ecto,
    name: "ecto_arto3",
    status: "online",
    meta:
      build(
        :artifact_metadata,
        location: "Paris",
        scale_min: 1,
        scale_max: 10,
        scale_factor: 2
      ),
    stats:
      build(
        :artifact_stats,
        invocation_rate: [
          [1_167_609_600_000, 7537],
          [1_167_696_000_000, 7537],
          [1_167_782_400_000, 7559],
          [1_167_868_800_000, 7631],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 7757],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 767],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 7706],
          [1_169_769_600_000, 7752],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 7701],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 768],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 7613],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 7608],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 757],
          [1_172_707_200_000, 7562],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7645],
          [1_173_139_200_000, 7635],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 7604],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 7602],
          [1_173_744_000_000, 7566],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 7562],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 7518],
          [1_174_348_800_000, 7522],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 7491],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        replica_scaling: [
          [1_167_609_600_000, 753],
          [1_167_696_000_000, 753],
          [1_167_782_400_000, 759],
          [1_167_868_800_000, 731],
          [1_167_955_200_000, 744],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 777],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 76],
          [1_169_769_600_000, 52],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 771],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 13],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 78],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 75],
          [1_172_707_200_000, 762],
          [1_172_793_600_000, 75983],
          [1_173_052_800_000, 645],
          [1_173_139_200_000, 735],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 604],
          [1_173_398_400_000, 76033],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 75],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 752],
          [1_174_003_200_000, 72506],
          [1_174_262_400_000, 718],
          [1_174_348_800_000, 752],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 749],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        execution_duration: [
          [1_167_609_600_000, 37],
          [1_167_696_000_000, 75347],
          [1_167_782_400_000, 9559],
          [1_167_868_800_000, 31],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 79],
          [1_168_300_800_000, 76833],
          [1_168_387_200_000, 7],
          [1_168_473_600_000, 77],
          [1_168_560_000_000, 775],
          [1_168_819_200_000, 77284],
          [1_168_905_600_000, 77221],
          [1_168_992_000_000, 48],
          [1_169_078_400_000, 77],
          [1_169_164_800_000, 77185],
          [1_169_424_000_000, 77313],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 69],
          [1_169_683_200_000, 77],
          [1_169_769_600_000, 77523],
          [1_170_028_800_000, 7],
          [1_170_115_200_000, 7],
          [1_170_201_600_000, 721],
          [1_170_288_000_000, 81],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 773],
          [1_170_720_000_000, 7],
          [1_170_806_400_000, 701],
          [1_170_892_800_000, 76990],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 345],
          [1_171_497_600_000, 76130],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 76106],
          [1_171_929_600_000, 608],
          [1_172_016_000_000, 008],
          [1_172_102_400_000, 76313],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 7],
          [1_172_534_400_000, 56],
          [1_172_620_800_000, 257],
          [1_172_707_200_000, 75362],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7],
          [1_173_139_200_000, 35],
          [1_173_225_600_000, 714],
          [1_173_312_000_000, 74],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 66],
          [1_173_830_400_000, 757],
          [1_173_916_800_000, 75],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 14],
          [1_174_348_800_000, 722],
          [1_174_435_200_000, 754],
          [1_174_521_600_000, 74],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 744],
          [1_174_953_600_000, 7343]
        ]
      )
  )

  insert(
    :artifact,
    experiment: ecto_exp4,
    project: ecto,
    name: "ecto_arto4",
    status: "online",
    meta:
      build(
        :artifact_metadata,
        location: "Paris",
        scale_min: 1,
        scale_max: 10,
        scale_factor: 2
      ),
    stats:
      build(
        :artifact_stats,
        invocation_rate: [
          [1_167_609_600_000, 7537],
          [1_167_696_000_000, 7537],
          [1_167_782_400_000, 7559],
          [1_167_868_800_000, 7631],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 7757],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 767],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 7706],
          [1_169_769_600_000, 7752],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 7701],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 768],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 7613],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 7608],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 757],
          [1_172_707_200_000, 7562],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7645],
          [1_173_139_200_000, 7635],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 7604],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 7602],
          [1_173_744_000_000, 7566],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 7562],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 7518],
          [1_174_348_800_000, 7522],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 7491],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        replica_scaling: [
          [1_167_609_600_000, 753],
          [1_167_696_000_000, 753],
          [1_167_782_400_000, 759],
          [1_167_868_800_000, 731],
          [1_167_955_200_000, 744],
          [1_168_214_400_000, 769],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 77],
          [1_168_473_600_000, 7703],
          [1_168_560_000_000, 777],
          [1_168_819_200_000, 7728],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 7748],
          [1_169_078_400_000, 774],
          [1_169_164_800_000, 7718],
          [1_169_424_000_000, 7731],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 769],
          [1_169_683_200_000, 76],
          [1_169_769_600_000, 52],
          [1_170_028_800_000, 774],
          [1_170_115_200_000, 771],
          [1_170_201_600_000, 7721],
          [1_170_288_000_000, 7681],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 7738],
          [1_170_720_000_000, 772],
          [1_170_806_400_000, 771],
          [1_170_892_800_000, 7699],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 7645],
          [1_171_497_600_000, 13],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 7616],
          [1_171_929_600_000, 78],
          [1_172_016_000_000, 7608],
          [1_172_102_400_000, 7631],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 76],
          [1_172_534_400_000, 756],
          [1_172_620_800_000, 75],
          [1_172_707_200_000, 762],
          [1_172_793_600_000, 75983],
          [1_173_052_800_000, 645],
          [1_173_139_200_000, 735],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 604],
          [1_173_398_400_000, 76033],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 75],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 752],
          [1_174_003_200_000, 72506],
          [1_174_262_400_000, 718],
          [1_174_348_800_000, 752],
          [1_174_435_200_000, 7524],
          [1_174_521_600_000, 749],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 754],
          [1_174_953_600_000, 7493]
        ],
        execution_duration: [
          [1_167_609_600_000, 37],
          [1_167_696_000_000, 75347],
          [1_167_782_400_000, 9559],
          [1_167_868_800_000, 31],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 79],
          [1_168_300_800_000, 76833],
          [1_168_387_200_000, 7],
          [1_168_473_600_000, 77],
          [1_168_560_000_000, 775],
          [1_168_819_200_000, 77284],
          [1_168_905_600_000, 77221],
          [1_168_992_000_000, 48],
          [1_169_078_400_000, 77],
          [1_169_164_800_000, 77185],
          [1_169_424_000_000, 77313],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 69],
          [1_169_683_200_000, 77],
          [1_169_769_600_000, 77523],
          [1_170_028_800_000, 7],
          [1_170_115_200_000, 7],
          [1_170_201_600_000, 721],
          [1_170_288_000_000, 81],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 773],
          [1_170_720_000_000, 7],
          [1_170_806_400_000, 701],
          [1_170_892_800_000, 76990],
          [1_170_979_200_000, 7689],
          [1_171_238_400_000, 7719],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 345],
          [1_171_497_600_000, 76130],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 76106],
          [1_171_929_600_000, 608],
          [1_172_016_000_000, 008],
          [1_172_102_400_000, 76313],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 7],
          [1_172_534_400_000, 56],
          [1_172_620_800_000, 257],
          [1_172_707_200_000, 75362],
          [1_172_793_600_000, 7598],
          [1_173_052_800_000, 7],
          [1_173_139_200_000, 35],
          [1_173_225_600_000, 714],
          [1_173_312_000_000, 74],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 66],
          [1_173_830_400_000, 757],
          [1_173_916_800_000, 75],
          [1_174_003_200_000, 7506],
          [1_174_262_400_000, 14],
          [1_174_348_800_000, 722],
          [1_174_435_200_000, 754],
          [1_174_521_600_000, 74],
          [1_174_608_000_000, 7505],
          [1_174_867_200_000, 744],
          [1_174_953_600_000, 7343]
        ]
      )
  )
end)
