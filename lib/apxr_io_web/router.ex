defmodule ApxrIoWeb.Router do
  use ApxrIoWeb, :router
  use Plug.ErrorHandler

  @accepted_formats ~w(json elixir erlang)

  @csp "default-src 'self';\
        connect-src 'self';\
        script-src 'self' 'unsafe-inline' 'unsafe-eval';\
        style-src 'self' 'unsafe-inline' 'unsafe-eval';\
        img-src 'self' 'unsafe-inline' 'unsafe-eval';\
        font-src 'self' 'unsafe-inline' 'unsafe-eval';"

  @checks [%PlugCheckup.Check{name: "DB", module: ApxrIoWeb.HealthChecks, function: :check_db}]

  forward("/health", PlugCheckup, PlugCheckup.Options.new(json_encoder: Jason, checks: @checks))

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :web_user_agent
    plug :validate_url
    plug :login
  end

  pipeline :upload do
    plug :read_body_finally
    plug :accepts, @accepted_formats
    plug :user_agent
    plug :authenticate
    plug :validate_url
    plug ApxrIoWeb.Plugs.Attack
    plug :fetch_body
  end

  pipeline :api do
    plug :accepts, @accepted_formats
    plug :user_agent
    plug :authenticate
    plug :validate_url
    plug ApxrIoWeb.Plugs.Attack
    plug Corsica, origins: "*", allow_methods: ["HEAD", "GET"]
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", ApxrIoWeb do
    pipe_through :browser
    get "/", LoginController, :new
    get "/about", PageController, :about

    get "/login/:auth_token", LoginController, :login
    get "/login", LoginController, :new
    post "/login", LoginController, :create
    post "/logout", LoginController, :delete

    get "/signup", SignupController, :show
    post "/signup", SignupController, :create

    get "/email/verify", EmailVerificationController, :verify
    get "/email/verification", EmailVerificationController, :show
    post "/email/verification", EmailVerificationController, :create

    get "/settings", SettingsController, :index

    get "/teams", TeamController, :index
    get "/teams/new", TeamController, :new
    post "/teams", TeamController, :create
    get "/teams/:team/members", TeamController, :members
    get "/teams/:team/audit_log", TeamController, :audit_log
    post "/teams/:team", TeamController, :update

    delete "/users/:username", UserController, :delete

    get "/docs", DocsController, :index
    get "/docs/public_keys", DocsController, :public_keys

    get "/policies/privacy", PolicyController, :privacy
    get "/policies/terms-of-use", PolicyController, :tou

    get "/projects", ProjectController, :index
    get "/projects/:name", ProjectController, :show
    get "/projects/:name/:version", ProjectController, :show
  end

  scope "/settings", ApxrIoWeb.Settings do
    pipe_through :browser

    get "/profile", ProfileController, :index
    get "/profile/audit_log", ProfileController, :audit_log
    get "/profile/export_data", ProfileController, :export_data
    post "/profile", ProfileController, :update

    get "/email", EmailController, :index
    post "/email", EmailController, :create
    delete "/email", EmailController, :delete
    post "/email/primary", EmailController, :primary
    post "/email/resend", EmailController, :resend_verify

    get "/keys", KeyController, :index, as: :settings_key
    delete("/keys/:name", KeyController, :delete, as: :settings_key)
    post "/keys", KeyController, :create, as: :settings_key
  end

  scope "/teams", ApxrIoWeb.Teams do
    pipe_through :browser

    get "/:team/keys", KeyController, :index, as: :teams_key
    post "/:team/keys", KeyController, :create, as: :teams_key
    delete "/:team/keys/:name", KeyController, :delete, as: :teams_key
  end

  scope "/projects", ApxrIoWeb.Projects do
    pipe_through :browser

    get "/:project/experiments/all", ExperimentController, :index
    get "/:project/releases/:version/experiments/:id", ExperimentController, :show

    get "/:project/artifacts/all", ArtifactController, :index
    get "/:project/artifacts/:name", ArtifactController, :show

    scope "/:project/artifacts", Artifacts do
      get "/:artifact/keys", KeyController, :index, as: :artifacts_key
      delete("/:artifact/keys/:name", KeyController, :delete, as: :artifacts_key)
      post "/:artifact/keys", KeyController, :create, as: :artifacts_key
    end
  end

  scope "/api", ApxrIoWeb.API, as: :api do
    pipe_through :upload

    for prefix <- ["/repos/:repository"] do
      scope prefix do
        post "/projects/:name/releases", ReleaseController, :create

        post "/projects/:name/releases/:version/experiments", ExperimentController, :create
        post "/projects/:name/releases/:version/experiments/:id", ExperimentController, :update

        post "/projects/:name/artifacts", ArtifactController, :create
        post "/projects/:name/artifacts/:artifact", ArtifactController, :update
        post "/projects/:name/artifacts/:artifact/unpublish", ArtifactController, :unpublish
        post "/projects/:name/artifacts/:artifact/republish", ArtifactController, :republish
      end
    end
  end

  scope "/api", ApxrIoWeb.API, as: :api do
    pipe_through :api

    post "/users", UserController, :create
    get "/users/me", UserController, :me

    get "/repos", RepositoryController, :index
    get "/repos/:repository", RepositoryController, :show

    for prefix <- ["/repos/:repository"] do
      scope prefix do
        get "/projects", ProjectController, :index
        get "/projects/:name", ProjectController, :show

        get "/projects/:name/releases/:version", ReleaseController, :show
        get "/projects/:name/releases/:version/tarball", ReleaseController, :tarball
        delete "/projects/:name/releases/:version", ReleaseController, :delete

        post "/projects/:name/releases/:version/retire", RetirementController, :create
        delete "/projects/:name/releases/:version/retire", RetirementController, :delete

        get "/projects/:name/owners", OwnerController, :index
        get "/projects/:name/owners/:email", OwnerController, :show
        put "/projects/:name/owners/:email", OwnerController, :create
        delete "/projects/:name/owners/:email", OwnerController, :delete

        get "/projects/:name/experiments/all", ExperimentController, :index
        get "/projects/:name/releases/:version/experiments/:id", ExperimentController, :show

        post "/projects/:name/releases/:version/experiments/:id/pause",
             ExperimentController,
             :pause

        post "/projects/:name/releases/:version/experiments/:id/continue",
             ExperimentController,
             :continue

        post "/projects/:name/releases/:version/experiments/:id/stop", ExperimentController, :stop
        delete "/projects/:name/releases/:version/experiments/:id", ExperimentController, :delete

        get "/projects/:name/artifacts/all", ArtifactController, :index
        get "/projects/:name/artifacts/:artifact", ArtifactController, :show
        delete "/projects/:name/artifacts/:artifact", ArtifactController, :delete
      end
    end

    for prefix <- ["/", "/teams/:team", "/artifacts/:artifact"] do
      scope prefix do
        get "/keys", KeyController, :index
        get "/keys/:name", KeyController, :show
        post "/keys", KeyController, :create
        delete "/keys", KeyController, :delete_all
        delete "/keys/:name", KeyController, :delete
      end
    end

    get "/auth", AuthController, :show
  end

  if Mix.env() in [:dev, :test, :apxr_sh] do
    scope "/api", ApxrIoWeb do
      pipe_through :api

      post "/repo", TestController, :repo
      post "/keys/test", TestController, :keys
    end
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: _stacktrace}) do
    if report?(kind, reason) do
      conn = maybe_fetch_params(conn)
      url = "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}"
      user_ip = conn.remote_ip |> :inet.ntoa() |> List.to_string()
      headers = conn.req_headers |> Map.new() |> filter_headers()
      params = filter_params(conn.params)
      endpoint_url = ApxrIoWeb.Endpoint.config(:url)

      %{
        "request" => %{
          "url" => url,
          "user_ip" => user_ip,
          "headers" => headers,
          "params" => params,
          "method" => conn.method
        },
        "server" => %{
          "host" => endpoint_url[:host],
          "root" => endpoint_url[:path]
        }
      }
    end
  end

  defp report?(:error, exception), do: Plug.Exception.status(exception) == 500
  defp report?(_kind, _reason), do: true

  defp maybe_fetch_params(conn) do
    Plug.Conn.fetch_query_params(conn)
  rescue
    _ ->
      %{conn | params: "[UNFETCHED]"}
  end

  @filter_headers ~w(authorization)

  defp filter_headers(headers) do
    Map.drop(headers, @filter_headers)
  end

  @filter_params ~w(body auth_token token)

  defp filter_params(params) when is_map(params) do
    Map.new(params, fn {key, value} ->
      if key in @filter_params do
        {key, "[FILTERED]"}
      else
        {key, filter_params(value)}
      end
    end)
  end

  defp filter_params(params) when is_list(params) do
    Enum.map(params, &filter_params/1)
  end

  defp filter_params(other) do
    other
  end
end
