defmodule ApxrIoWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use ApxrIoWeb, :controller
      use ApxrIoWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def schema() do
    quote do
      use Ecto.Schema
      @timestamps_opts [type: :utc_datetime_usec]

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import ApxrIo.Changeset

      alias Ecto.Multi

      ApxrIoWeb.shared()
    end
  end

  def context() do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import ApxrIo.Accounts.AuditLog, only: [audit: 4, audit_many: 4, audit_with_user: 4]

      alias Ecto.Multi

      alias ApxrIo.{Emails, Emails.Mailer, Repo}

      ApxrIoWeb.shared()
    end
  end

  def controller() do
    quote do
      use Phoenix.Controller, namespace: ApxrIoWeb

      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]

      import ApxrIoWeb.{ControllerHelpers, AuthHelpers}

      alias ApxrIoWeb.Endpoint
      alias ApxrIoWeb.Router.Helpers, as: Routes

      ApxrIoWeb.shared()
    end
  end

  def view() do
    quote do
      use Phoenix.View,
        root: "lib/apxr_io_web/templates",
        namespace: ApxrIoWeb

      use Phoenix.HTML

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      import Phoenix.HTML.Form,
        except: [
          text_input: 2,
          text_input: 3,
          email_input: 2,
          email_input: 3,
          password_input: 2,
          password_input: 3,
          select: 3,
          select: 4
        ]

      import ApxrIoWeb.ViewHelpers

      alias ApxrIoWeb.Endpoint
      alias ApxrIoWeb.Router.Helpers, as: Routes

      ApxrIoWeb.shared()
    end
  end

  def router() do
    quote do
      use Phoenix.Router
      import ApxrIoWeb.Plugs
    end
  end

  defmacro shared do
    quote do
      alias ApxrIo.{
        Accounts.Auth,
        Accounts.AuditLog,
        Accounts.Email,
        Accounts.Key,
        Accounts.Keys,
        Accounts.KeyPermission,
        Accounts.Team,
        Accounts.Teams,
        Accounts.TeamUser,
        Accounts.Session,
        Accounts.User,
        Accounts.Users,
        Accounts.Host,
        Accounts.Hosts,
        CMS.Post,
        CMS.Blog,
        Emails,
        Emails.Mailer,
        Learn.Experiment,
        Learn.Experiments,
        Learn.ExperimentMetadata,
        Learn.ExperimentTrace,
        Learn.ExperimentGraphData,
        Learn.ExperimentSystemMetrics,
        Repository.Assets,
        Repository.Owners,
        Repository.Project,
        Repository.Projects,
        Repository.ProjectMetadata,
        Repository.ProjectOwner,
        Repository.RegistryBuilder,
        Repository.Release,
        Repository.Releases,
        Repository.ReleaseMetadata,
        Repository.ReleaseRetirement,
        Repository.Repository,
        Serve.Artifact,
        Serve.Artifacts,
        Serve.ArtifactMetadata,
        Serve.ArtifactStats,
        Serve.Gateway
      }
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
