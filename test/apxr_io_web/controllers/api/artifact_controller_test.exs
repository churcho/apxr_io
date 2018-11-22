defmodule ApxrIoWeb.API.ArtifactControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIo.Accounts.AuditLog
  alias ApxrIo.Serve.Artifact
  alias ApxrIo.Serve.Artifacts

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

    experiment2 =
      insert(
        :experiment,
        description: "SDQFQLSMDFLM",
        release: release2,
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

    experiment3 =
      insert(
        :experiment,
        description: "SDQFQLSMDFLM",
        release: release3,
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

    artifact =
      insert(
        :artifact,
        experiment: experiment,
        project: project,
        name: "artifact_name",
        status: "offline",
        meta:
          build(
            :artifact_metadata,
            location: "Paris",
            scale_min: 1,
            scale_max: 10,
            scale_factor: 2
          )
      )

    artifact2 = %{
      experiment_id: experiment2.id,
      project_id: project.id,
      name: "artifact_name2",
      status: "offline",
      meta: %{
        location: "Paris",
        scale_min: 1,
        scale_max: 10,
        scale_factor: 2
      }
    }

    artifact3 = %{
      experiment_id: experiment3.id,
      project_id: project.id,
      name: "artifact_name3",
      status: "offline",
      meta: %{
        location: "Paris",
        scale_min: 1,
        scale_max: 10,
        scale_factor: 2
      }
    }

    uartifact = %{
      meta: %{
        location: "Paris",
        scale_min: 1,
        scale_max: 10,
        scale_factor: 2
      },
      stats: %{
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
          [1_172_793_600_000, 7593],
          [1_173_052_800_000, 645],
          [1_173_139_200_000, 735],
          [1_173_225_600_000, 7614],
          [1_173_312_000_000, 604],
          [1_173_398_400_000, 7603],
          [1_173_657_600_000, 702],
          [1_173_744_000_000, 75],
          [1_173_830_400_000, 7587],
          [1_173_916_800_000, 752],
          [1_174_003_200_000, 7256],
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
          [1_167_696_000_000, 7534],
          [1_167_782_400_000, 9559],
          [1_167_868_800_000, 31],
          [1_167_955_200_000, 7644],
          [1_168_214_400_000, 79],
          [1_168_300_800_000, 7683],
          [1_168_387_200_000, 7],
          [1_168_473_600_000, 77],
          [1_168_560_000_000, 775],
          [1_168_819_200_000, 7284],
          [1_168_905_600_000, 7721],
          [1_168_992_000_000, 48],
          [1_169_078_400_000, 77],
          [1_169_164_800_000, 7715],
          [1_169_424_000_000, 7713],
          [1_169_510_400_000, 77],
          [1_169_596_800_000, 69],
          [1_169_683_200_000, 77],
          [1_169_769_600_000, 7523],
          [1_170_028_800_000, 7],
          [1_170_115_200_000, 7],
          [1_170_201_600_000, 721],
          [1_170_288_000_000, 81],
          [1_170_374_400_000, 7681],
          [1_170_633_600_000, 773],
          [1_170_720_000_000, 7],
          [1_170_806_400_000, 701],
          [1_170_892_800_000, 790],
          [1_170_979_200_000, 768],
          [1_171_238_400_000, 771],
          [1_171_324_800_000, 78],
          [1_171_411_200_000, 345],
          [1_171_497_600_000, 760],
          [1_171_584_000_000, 7624],
          [1_171_843_200_000, 766],
          [1_171_929_600_000, 608],
          [1_172_016_000_000, 008],
          [1_172_102_400_000, 763],
          [1_172_188_800_000, 7615],
          [1_172_448_000_000, 7],
          [1_172_534_400_000, 56],
          [1_172_620_800_000, 257],
          [1_172_707_200_000, 7532],
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
      }
    }

    %{
      project: project,
      project2: project2,
      project3: project3,
      project4: project4,
      release: release,
      artifact: artifact,
      artifact2: artifact2,
      artifact3: artifact3,
      uartifact: uartifact,
      team: team,
      nbteam: nbteam,
      user: user,
      unauthorized_user: unauthorized_user
    }
  end

  describe "GET /api/repos/:repo/projects/:project/artifacts/all" do
    test "show artifacts in project", %{
      user: user,
      team: team,
      project: project
    } do
      result =
        build_conn()
        |> put_req_header("authorization", key_for(user))
        |> get("api/repos/#{team.name}/projects/#{project.name}/artifacts/all")
        |> json_response(200)

      assert length(result) == 1
    end

    test "show artifacts in team authorizes", %{
      team: team,
      unauthorized_user: unauthorized_user,
      project: project
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects/#{project.name}/artifacts/all")
      |> json_response(401)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> get("api/repos/#{team.name}/projects/#{project.name}/artifacts/all")
      |> json_response(403)
    end
  end

  describe "GET /api/repos/:repo/projects/:project/artifacts/:name" do
    test "get artifact unauthenticated", %{
      team: team,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> get("api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}")
      |> json_response(401)
    end

    test "get project returns 404 for unknown team", %{
      user: user,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/UNKNOWN_REPOSITORY/projects/#{project.name}/artifacts/#{artifact.name}")
      |> json_response(404)
    end

    test "get artifact returns 404 for unknown project if you are authorized", %{
      user: user,
      team: team,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> get("api/repos/#{team.name}/projects/UNKNOWN_PROJECT/artifacts/#{artifact.name}")
      |> json_response(404)
    end
  end

  describe "POST /api/repos/:repo/:project/artifacts" do
    test "create artifact authorizes", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      artifact3: artifact3
    } do
      artifact_count = Artifacts.count(project)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> json_post("api/repos/#{team.name}/projects/#{project.name}/artifacts", %{
        "artifact" => artifact3
      })
      |> json_response(403)

      assert artifact_count == Artifacts.count(project)
    end

    test "artifact requries write permission", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      artifact3: artifact3
    } do
      insert(:team_user, team: team, user: unauthorized_user, role: "read")

      artifact_count = Artifacts.count(project)

      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> json_post("api/repos/#{team.name}/projects/#{project.name}/artifacts", %{
        "artifact" => artifact3
      })
      |> json_response(403)

      assert artifact_count == Artifacts.count(project)
    end

    test "team needs to have active billing", %{
      nbteam: nbteam,
      project3: project3,
      artifact3: artifact3
    } do
      user = insert(:user)

      insert(:team_user, team: nbteam, user: user, role: "write")

      artifact_count = Artifacts.count(project3)

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post("api/repos/#{nbteam.name}/projects/#{project3.name}/artifacts", %{
        "artifact" => artifact3
      })
      |> json_response(403)

      assert artifact_count == Artifacts.count(project3)
    end

    test "create artifact", %{
      team: team,
      project: project,
      artifact2: artifact2
    } do
      artifact_count = Artifacts.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post("api/repos/#{team.name}/projects/#{project.name}/artifacts", %{
        "artifact" => artifact2
      })
      |> json_response(201)

      assert artifact_count + 1 == Artifacts.count(project)

      log = ApxrIo.Repo.one!(AuditLog)
      assert log.user_id == user.id
      assert log.team_id == team.id
      assert log.action == "artifact.publish"
      assert log.params["project"]["name"] == project.name
    end
  end

  describe "POST /api/repos/:repo/projects/:project/artifacts/:name" do
    test "update artifact authorizes", %{
      user: user,
      team: team,
      project: project,
      artifact: artifact,
      uartifact: uartifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}",
        %{"data" => uartifact}
      )
      |> json_response(403)
    end

    test "update artifact", %{
      team: team,
      project: project,
      artifact: artifact,
      uartifact: uartifact
    } do
      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}",
        %{"data" => uartifact}
      )
      |> json_response(201)
    end
  end

  describe "POST /api/repos/:repo/projects/:project/artifacts/:name/unpublish" do
    test "unpublish artifact authorizes", %{
      user: user,
      team: team,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}/unpublish",
        %{}
      )
      |> json_response(403)
    end

    test "unpublish artifact", %{
      team: team,
      project: project,
      artifact: artifact
    } do
      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}/unpublish",
        %{}
      )
      |> json_response(201)
    end
  end

  describe "POST /api/repos/:repo/projects/:project/artifacts/:name/republish" do
    test "republish artifact authorizes", %{
      user: user,
      team: team,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}/republish",
        %{}
      )
      |> json_response(403)
    end

    test "republish artifact", %{
      team: team,
      project: project,
      artifact: artifact
    } do
      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "write")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> json_post(
        "api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}/republish",
        %{}
      )
      |> json_response(201)
    end
  end

  describe "DELETE /api/repos/:repo/projects/:project/artifacts/:name" do
    test "authorizes", %{
      unauthorized_user: unauthorized_user,
      team: team,
      project: project,
      artifact: artifact
    } do
      build_conn()
      |> put_req_header("authorization", key_for(unauthorized_user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}")
      |> response(403)

      assert ApxrIo.Repo.get_by!(Artifact, id: artifact.id)
    end

    test "delete artifact", %{
      team: team,
      project: project,
      artifact: artifact
    } do
      artifact_count = Artifacts.count(project)

      user = insert(:user)

      insert(:team_user, team: team, user: user, role: "admin")

      build_conn()
      |> put_req_header("authorization", key_for(user))
      |> delete("api/repos/#{team.name}/projects/#{project.name}/artifacts/#{artifact.name}")
      |> response(204)

      refute ApxrIo.Repo.get_by(Artifact, id: artifact.id)
      assert artifact_count - 1 == Artifacts.count(project)

      [log] = ApxrIo.Repo.all(AuditLog)
      assert log.user_id == user.id
      assert log.action == "artifact.delete"
      assert log.params["project"]["name"] == project.name
    end
  end
end
