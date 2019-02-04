defmodule ApxrIo.Factory do
  use ExMachina.Ecto, repo: ApxrIo.Repo
  alias ApxrIo.Fake

  def post_factory() do
    %ApxrIo.CMS.Post{
      title: "Projects & Teams",
      slug: "projects-and-teams",
      author: "Alex Smith",
      body: post_body(),
      published: true
    }
  end

  defp post_body() do
    "We are announcing the addition of private projects on approximatereality.com. With private projects you can publish
projects to approximatereality.com that only your team members can access and download. With your team
you get a repository namespace on approximatereality.com so that your private projects will not conflict with projects
in the global, public repository.


This will be a paid feature based on the number of members in your team. We have sponsorships
from Plataformatec and Fastly to help with some of the hosting and CDN costs, but there are still
associated costs with running approximatereality.com that hopefully this can help offset. Furthermore, private projects
provide a different set of features and require a private infrastructure that introduces complexity and
costs more to maintain.


Pushing public projects will of course stay free and if you run an open source project
that needs private projects you can contact us to get free access. The revenue from private
projects will help us increase the quality of both public and private services.


This feature is currently in beta and there are still missing features, most notably billing and documentation
hosting on hexdocs.pm. If you want to try it or help beta test private projects, please fill out the
sign up form to request access.


Even though we are introducing paid features everything around ApxrIo will stay open source, the only closed
source part will be the billing service."
  end

  def user_factory() do
    %ApxrIo.Accounts.User{
      username: Fake.sequence(:username),
      emails: [build(:email)]
    }
  end

  def email_factory() do
    email = Fake.sequence(:email)

    %ApxrIo.Accounts.Email{
      email: email,
      email_hash: email,
      verified: true,
      primary: true
    }
  end

  def key_factory() do
    {user_secret, first, second} = ApxrIo.Accounts.Key.gen_key()

    %ApxrIo.Accounts.Key{
      name: Fake.random(:username),
      secret_first: first,
      secret_second: second,
      user_secret: user_secret,
      permissions: [build(:key_permission, domain: "api")],
      user: nil,
      team: nil
    }
  end

  def key_permission_factory() do
    %ApxrIo.Accounts.KeyPermission{}
  end

  def team_factory() do
    %ApxrIo.Accounts.Team{
      name: Fake.sequence(:project),
      billing_active: true
    }
  end

  def project_factory() do
    %ApxrIo.Repository.Project{
      name: Fake.sequence(:project),
      meta: build(:project_metadata)
    }
  end

  def project_metadata_factory() do
    %ApxrIo.Repository.ProjectMetadata{
      description: Fake.random(:sentence),
      licenses: ["MIT"]
    }
  end

  def project_owner_factory() do
    %ApxrIo.Repository.ProjectOwner{}
  end

  def team_user_factory() do
    %ApxrIo.Accounts.TeamUser{
      role: "read"
    }
  end

  def release_factory() do
    %ApxrIo.Repository.Release{
      version: "1.0.0",
      checksum: "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
      meta: build(:release_metadata)
    }
  end

  def release_metadata_factory() do
    %ApxrIo.Repository.ReleaseMetadata{
      build_tool: "elixir"
    }
  end

  def block_address_factory() do
    %ApxrIo.BlockAddress.Entry{
      comment: "blocked"
    }
  end

  def experiment_factory do
    %ApxrIo.Learn.Experiment{
      description: "Experiment description goes here.",
      release: build(:release),
      meta: build(:experiment_metadata),
      trace: build(:experiment_trace),
      graph_data: build(:experiment_graph_data)
    }
  end

  def experiment_metadata_factory do
    %ApxrIo.Learn.ExperimentMetadata{
      started: nil,
      completed: nil,
      duration: 80_600_000,
      progress: "completed",
      total_runs: 5,
      interruptions: [],
      exp_parameters: %{
        identifier: "local_test",
        public_scape: [],
        runs: 20,
        min_pimprovement: 0.0,
        search_params_mut_prob: 0.5,
        output_sat_limit: 1,
        ro_signal: [0.0],
        fitness_stagnation: false,
        population_mgr_efficiency: 1,
        interactive_selection: false,
        re_entry_probability: 0.0,
        shof_ratio: 1,
        selection_algorithm_efficiency: 1
      },
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
      init_constraints: [
        %{
          data: %{
            agent_encoding_types: [:substrate],
            annealing_parameters: [0.5],
            connection_architecture: :recurrent,
            heredity_types: [:darwinian],
            hof_distinguishers: [:tot_n],
            morphology: :dtm_morphology,
            mutation_operators: [
              [:mutate_weights, 1],
              [:add_bias, 1],
              [:remove_bias, 1],
              [:mutate_af, 1],
              [:add_outlink, 1],
              [:add_inlink, 1],
              [:add_neuron, 1],
              [:outsplice, 1],
              [:add_sensor, 1],
              [:add_actuator, 1],
              [:add_sensorlink, 1],
              [:add_actuatorlink, 1],
              [:mutate_plasticity_parameters, 1],
              [:add_cpp, 1],
              [:add_cep, 1]
            ],
            neural_afs: [:tanh, :relu],
            neural_aggr_fs: [:dot_product, :diff_product],
            neural_pfns: [:ojas],
            perturbation_ranges: [1],
            population_evo_alg_f: :generational,
            population_selection_f: :hof_competition,
            specie_distinguishers: [:tot_n],
            substrate_linkforms: [:l2l_feedforward, :jordan_recurrent],
            substrate_plasticities: [:abcn, :none],
            tot_topological_mutations_fs: [[:ncount_exponential, 0.5]],
            tuning_duration_f: [:wsize_proportional, 0.5],
            tuning_selection_fs: [:dynamic_random]
          }
        }
      ]
    }
  end

  def experiment_trace_factory do
    %ApxrIo.Learn.ExperimentTrace{
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
    }
  end

  def experiment_graph_data_factory do
    %ApxrIo.Learn.ExperimentGraphData{
      graph_acc: [
        %{
          graph: %{
            avg_fitness_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              avg_fitness: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12],
              fitness_std: [
                [118.1676, 132.4324001],
                [126.15, 124.75],
                [129.090400002]
              ]
            },
            avg_neurons_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              avg_neurons: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12],
              neurons_std: [
                [118.1676, 132.4324001],
                [126.15, 124.75],
                [129.090400002]
              ]
            },
            avg_diversity_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              avg_diversity: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12],
              diversity_std: [
                [118.1676, 132.4324001],
                [126.15, 124.75],
                [129.090400002]
              ]
            },
            max_fitness_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              max_fitness: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12]
            },
            avg_max_fitness_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              maxavg_fitness: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12]
            },
            avg_min_fitness_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              min_fitness: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12]
            },
            specie_pop_turnover_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              evaluations: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12]
            },
            validation_avg_fitness_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              validation_fitness: [122.00001, 126.0001, 115.52000012, 117.24000012, 149.12],
              validation_fitness_std: [
                [118.1676, 132.4324001],
                [126.15, 124.75],
                [129.090400002]
              ]
            },
            validation_max_fitness_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              validationmax_fitness: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12]
            },
            validation_min_fitness_vs_evaluations: %{
              morphology: "some_morphology",
              evaluation_index: [500, 1000, 1500, 2500, 3000],
              validationmin_fitness: [122.00001, 56.0001, 115.52000012, 117.24000012, 149.12]
            }
          }
        }
      ]
    }
  end

  def artifact_factory do
    %ApxrIo.Serve.Artifact{
      experiment: build(:experiment),
      project: build(:project),
      name: Fake.sequence(:project),
      status: "online",
      meta: build(:artifact_metadata),
      stats: build(:artifact_stats)
    }
  end

  def artifact_metadata_factory do
    %ApxrIo.Serve.ArtifactMetadata{
      location: "AMS",
      scale_min: 1,
      scale_max: 10,
      scale_factor: 2
    }
  end

  def artifact_stats_factory do
    %ApxrIo.Serve.ArtifactStats{
      invocation_rate: [
        [1_167_609_600_000, 609],
        [1_167_696_000_000, 696],
        [1_167_782_400_000, 782],
        [1_167_868_800_000, 868],
        [1_167_955_200_000, 955],
        [1_168_214_400_000, 214],
        [1_168_300_800_000, 300],
        [1_168_387_200_000, 387],
        [1_168_473_600_000, 473],
        [1_168_560_000_000, 560],
        [1_168_819_200_000, 819],
        [1_168_905_600_000, 905],
        [1_168_992_000_000, 992],
        [1_169_078_400_000, 078],
        [1_169_164_800_000, 164],
        [1_169_424_000_000, 424],
        [1_169_510_400_000, 510],
        [1_169_596_800_000, 596],
        [1_169_683_200_000, 683],
        [1_169_769_600_000, 769],
        [1_170_028_800_000, 028],
        [1_170_115_200_000, 115],
        [1_170_201_600_000, 201],
        [1_170_288_000_000, 288],
        [1_170_374_400_000, 374],
        [1_170_633_600_000, 633],
        [1_170_720_000_000, 720],
        [1_170_806_400_000, 806],
        [1_170_892_800_000, 892],
        [1_170_979_200_000, 979],
        [1_171_238_400_000, 238],
        [1_171_324_800_000, 324],
        [1_171_411_200_000, 411],
        [1_171_497_600_000, 497],
        [1_171_584_000_000, 584],
        [1_171_843_200_000, 843],
        [1_171_929_600_000, 929],
        [1_172_016_000_000, 016],
        [1_172_102_400_000, 102],
        [1_172_188_800_000, 188],
        [1_172_448_000_000, 448],
        [1_172_534_400_000, 534],
        [1_172_620_800_000, 620],
        [1_172_707_200_000, 707],
        [1_172_793_600_000, 793],
        [1_173_052_800_000, 052],
        [1_173_139_200_000, 139],
        [1_173_225_600_000, 225],
        [1_173_312_000_000, 312],
        [1_173_398_400_000, 398],
        [1_173_657_600_000, 657],
        [1_173_744_000_000, 744],
        [1_173_830_400_000, 830],
        [1_173_916_800_000, 916],
        [1_174_003_200_000, 003],
        [1_174_262_400_000, 262],
        [1_174_348_800_000, 348],
        [1_174_435_200_000, 435],
        [1_174_521_600_000, 521],
        [1_174_608_000_000, 608],
        [1_174_867_200_000, 867],
        [1_174_953_600_000, 953]
      ],
      replica_scaling: [
        [1_167_609_600_000, 6],
        [1_167_696_000_000, 6],
        [1_167_782_400_000, 7],
        [1_167_868_800_000, 8],
        [1_167_955_200_000, 9],
        [1_168_214_400_000, 2],
        [1_168_300_800_000, 3],
        [1_168_387_200_000, 3],
        [1_168_473_600_000, 4],
        [1_168_560_000_000, 5],
        [1_168_819_200_000, 8],
        [1_168_905_600_000, 9],
        [1_168_992_000_000, 9],
        [1_169_078_400_000, 0],
        [1_169_164_800_000, 1],
        [1_169_424_000_000, 4],
        [1_169_510_400_000, 5],
        [1_169_596_800_000, 5],
        [1_169_683_200_000, 6],
        [1_169_769_600_000, 7],
        [1_170_028_800_000, 0],
        [1_170_115_200_000, 1],
        [1_170_201_600_000, 2],
        [1_170_288_000_000, 2],
        [1_170_374_400_000, 3],
        [1_170_633_600_000, 6],
        [1_170_720_000_000, 7],
        [1_170_806_400_000, 8],
        [1_170_892_800_000, 8],
        [1_170_979_200_000, 9],
        [1_171_238_400_000, 2],
        [1_171_324_800_000, 3],
        [1_171_411_200_000, 4],
        [1_171_497_600_000, 4],
        [1_171_584_000_000, 5],
        [1_171_843_200_000, 8],
        [1_171_929_600_000, 9],
        [1_172_016_000_000, 0],
        [1_172_102_400_000, 1],
        [1_172_188_800_000, 1],
        [1_172_448_000_000, 4],
        [1_172_534_400_000, 5],
        [1_172_620_800_000, 6],
        [1_172_707_200_000, 7],
        [1_172_793_600_000, 7],
        [1_173_052_800_000, 0],
        [1_173_139_200_000, 1],
        [1_173_225_600_000, 2],
        [1_173_312_000_000, 3],
        [1_173_398_400_000, 3],
        [1_173_657_600_000, 6],
        [1_173_744_000_000, 7],
        [1_173_830_400_000, 8],
        [1_173_916_800_000, 9],
        [1_174_003_200_000, 0],
        [1_174_262_400_000, 2],
        [1_174_348_800_000, 3],
        [1_174_435_200_000, 4],
        [1_174_521_600_000, 5],
        [1_174_608_000_000, 6],
        [1_174_867_200_000, 8],
        [1_174_953_600_000, 9]
      ],
      execution_duration: [
        [1_167_609_600_000, 60],
        [1_167_696_000_000, 69],
        [1_167_782_400_000, 78],
        [1_167_868_800_000, 86],
        [1_167_955_200_000, 95],
        [1_168_214_400_000, 21],
        [1_168_300_800_000, 30],
        [1_168_387_200_000, 38],
        [1_168_473_600_000, 47],
        [1_168_560_000_000, 56],
        [1_168_819_200_000, 81],
        [1_168_905_600_000, 90],
        [1_168_992_000_000, 99],
        [1_169_078_400_000, 07],
        [1_169_164_800_000, 16],
        [1_169_424_000_000, 42],
        [1_169_510_400_000, 51],
        [1_169_596_800_000, 59],
        [1_169_683_200_000, 68],
        [1_169_769_600_000, 76],
        [1_170_028_800_000, 02],
        [1_170_115_200_000, 11],
        [1_170_201_600_000, 20],
        [1_170_288_000_000, 28],
        [1_170_374_400_000, 37],
        [1_170_633_600_000, 63],
        [1_170_720_000_000, 72],
        [1_170_806_400_000, 80],
        [1_170_892_800_000, 89],
        [1_170_979_200_000, 97],
        [1_171_238_400_000, 23],
        [1_171_324_800_000, 32],
        [1_171_411_200_000, 41],
        [1_171_497_600_000, 49],
        [1_171_584_000_000, 58],
        [1_171_843_200_000, 84],
        [1_171_929_600_000, 92],
        [1_172_016_000_000, 01],
        [1_172_102_400_000, 10],
        [1_172_188_800_000, 18],
        [1_172_448_000_000, 44],
        [1_172_534_400_000, 53],
        [1_172_620_800_000, 62],
        [1_172_707_200_000, 70],
        [1_172_793_600_000, 79],
        [1_173_052_800_000, 05],
        [1_173_139_200_000, 13],
        [1_173_225_600_000, 22],
        [1_173_312_000_000, 31],
        [1_173_398_400_000, 39],
        [1_173_657_600_000, 65],
        [1_173_744_000_000, 74],
        [1_173_830_400_000, 83],
        [1_173_916_800_000, 91],
        [1_174_003_200_000, 00],
        [1_174_262_400_000, 26],
        [1_174_348_800_000, 34],
        [1_174_435_200_000, 43],
        [1_174_521_600_000, 52],
        [1_174_608_000_000, 60],
        [1_174_867_200_000, 86],
        [1_174_953_600_000, 95]
      ]
    }
  end
end
