defmodule ApxrIoWeb.Projects.Artifacts.KeyControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  setup do
    user = insert(:user)
    team = insert(:team)

    project = insert(:project, team_id: team.id)

    rel =
      insert(
        :release,
        project: project,
        version: "0.0.1",
        meta: build(:release_metadata)
      )

    exp =
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

    artifact =
      insert(
        :artifact,
        experiment: exp,
        project: project,
        name: "artifqqsdfact",
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
              [1_172_793_600_000, 759],
              [1_173_052_800_000, 645],
              [1_173_139_200_000, 735],
              [1_173_225_600_000, 7614],
              [1_173_312_000_000, 604],
              [1_173_398_400_000, 733],
              [1_173_657_600_000, 702],
              [1_173_744_000_000, 75],
              [1_173_830_400_000, 7587],
              [1_173_916_800_000, 752],
              [1_174_003_200_000, 706],
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
              [1_167_696_000_000, 757],
              [1_167_782_400_000, 959],
              [1_167_868_800_000, 31],
              [1_167_955_200_000, 764],
              [1_168_214_400_000, 79],
              [1_168_300_800_000, 733],
              [1_168_387_200_000, 7],
              [1_168_473_600_000, 77],
              [1_168_560_000_000, 775],
              [1_168_819_200_000, 284],
              [1_168_905_600_000, 771],
              [1_168_992_000_000, 48],
              [1_169_078_400_000, 77],
              [1_169_164_800_000, 785],
              [1_169_424_000_000, 773],
              [1_169_510_400_000, 77],
              [1_169_596_800_000, 69],
              [1_169_683_200_000, 77],
              [1_169_769_600_000, 773],
              [1_170_028_800_000, 7],
              [1_170_115_200_000, 7],
              [1_170_201_600_000, 721],
              [1_170_288_000_000, 81],
              [1_170_374_400_000, 7681],
              [1_170_633_600_000, 773],
              [1_170_720_000_000, 7],
              [1_170_806_400_000, 701],
              [1_170_892_800_000, 760],
              [1_170_979_200_000, 7689],
              [1_171_238_400_000, 771],
              [1_171_324_800_000, 78],
              [1_171_411_200_000, 345],
              [1_171_497_600_000, 7610],
              [1_171_584_000_000, 7624],
              [1_171_843_200_000, 761],
              [1_171_929_600_000, 608],
              [1_172_016_000_000, 008],
              [1_172_102_400_000, 763],
              [1_172_188_800_000, 7615],
              [1_172_448_000_000, 7],
              [1_172_534_400_000, 56],
              [1_172_620_800_000, 257],
              [1_172_707_200_000, 753],
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

    %{
      team: team,
      user: user,
      project: project,
      experiment: exp,
      artifact: artifact
    }
  end

  defp mock_billing_settings(team) do
    Mox.stub(ApxrIo.Billing.Mock, :teams, fn token ->
      assert team.name == token

      %{
        "checkout_html" => "",
        "invoices" => []
      }
    end)
  end

  describe "POST /projects/:project/artifacts/:artifact/keys" do
    test "generate a new key", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")

      conn =
        build_conn()
        |> test_login(c.user)
        |> post(
          "/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys",
          %{key: %{name: "computer"}}
        )

      assert redirected_to(conn) ==
               "/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys"

      assert get_flash(conn, :info) =~ "The key computer was successfully generated"
    end
  end

  describe "DELETE /projects/:project/artifacts/:artifact/keys" do
    test "revoke key", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")
      key = insert(:key, artifact: c.artifact, name: "computer")

      mock_billing_settings(c.team)

      conn =
        build_conn()
        |> test_login(c.user)
        |> delete("/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys/#{key.name}")

      assert redirected_to(conn) ==
               "/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys"

      assert get_flash(conn, :info) =~ "The key computer was revoked successfully"
    end

    test "revoking an already revoked key throws an error", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")

      key =
        insert(:key,
          team: c.team,
          name: "computer",
          revoked_at: ~N"2017-01-01 00:00:00"
        )

      mock_billing_settings(c.team)

      conn =
        build_conn()
        |> test_login(c.user)
        |> delete("/projects/#{c.project.name}/artifacts/#{c.artifact.name}/keys/#{key.name}")

      assert response(conn, 400) =~ "The key computer was not found"
    end
  end
end
