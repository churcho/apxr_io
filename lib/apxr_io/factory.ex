defmodule ApxrIo.Factory do
  use ExMachina.Ecto, repo: ApxrIo.Repo
  alias ApxrIo.Fake

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
    %ApxrIo.Learn.Experiment{}
  end

  def experiment_metadata_factory do
    %ApxrIo.Learn.ExperimentMetadata{}
  end

  def experiment_trace_factory do
    %ApxrIo.Learn.ExperimentTrace{}
  end

  def experiment_graph_data_factory do
    %ApxrIo.Learn.ExperimentGraphData{}
  end

  def artifact_factory do
    %ApxrIo.Serve.Artifact{}
  end

  def artifact_metadata_factory do
    %ApxrIo.Serve.ArtifactMetadata{}
  end

  def artifact_stats_factory do
    %ApxrIo.Serve.ArtifactStats{}
  end
end
