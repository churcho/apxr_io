defmodule ApxrIoWeb.API.InstallControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    user = insert(:user)
    team = insert(:team)
    insert(:team_user, user: user, team: team)
    %{user: user}
  end

  test "installs", context do
    versions = [
      {"0.0.1", ["0.13.0-dev"]},
      {"0.1.0", ["0.13.1-dev"]},
      {"0.1.1", ["0.13.1-dev"]},
      {"0.1.2", ["0.13.1-dev"]},
      {"0.2.0", ["0.14.0", "0.14.1", "0.14.2"]},
      {"0.2.1", ["1.0.0"]}
    ]

    Enum.each(versions, fn {apxr_io, elixirs} ->
      ApxrIo.Repository.Install.build(apxr_io, elixirs)
      |> ApxrIo.Repo.insert()
    end)

    conn =
      build_conn()
      |> put_req_header("authorization", key_for(context.user))
      |> get("api/installs/apxr_sh.ez")

    assert redirected_to(conn) == "http://s3.apxr_io.com/installs/1.0.0/apxr_sh.ez"

    conn =
      build_conn()
      |> put_req_header("authorization", key_for(context.user))
      |> get("api/installs/apxr_sh.ez?elixir=0.0.1")

    assert redirected_to(conn) == "http://s3.apxr_io.com/installs/apxr_sh.ez"

    conn =
      build_conn()
      |> put_req_header("authorization", key_for(context.user))
      |> get("api/installs/apxr_sh.ez?elixir=0.13.0")

    assert redirected_to(conn) == "http://s3.apxr_io.com/installs/0.13.0-dev/apxr_sh.ez"

    conn =
      build_conn()
      |> put_req_header("authorization", key_for(context.user))
      |> get("api/installs/apxr_sh.ez?elixir=0.13.1")

    assert redirected_to(conn) == "http://s3.apxr_io.com/installs/0.13.1-dev/apxr_sh.ez"

    conn =
      build_conn()
      |> put_req_header("authorization", key_for(context.user))
      |> get("api/installs/apxr_sh.ez?elixir=0.14.0")

    assert redirected_to(conn) == "http://s3.apxr_io.com/installs/0.14.0/apxr_sh.ez"

    conn =
      build_conn()
      |> put_req_header("authorization", key_for(context.user))
      |> get("api/installs/apxr_sh.ez?elixir=0.14.1-dev")

    assert redirected_to(conn) == "http://s3.apxr_io.com/installs/0.14.0/apxr_sh.ez"

    conn =
      build_conn()
      |> put_req_header("authorization", key_for(context.user))
      |> get("api/installs/apxr_sh.ez?elixir=0.14.1")

    assert redirected_to(conn) == "http://s3.apxr_io.com/installs/0.14.1/apxr_sh.ez"

    conn =
      build_conn()
      |> put_req_header("authorization", key_for(context.user))
      |> get("api/installs/apxr_sh.ez?elixir=0.14.2")

    assert redirected_to(conn) == "http://s3.apxr_io.com/installs/0.14.2/apxr_sh.ez"

    build_conn()
    |> put_req_header("user-agent", "Mix/0.14.1-dev")
    |> get("api/installs/apxr_sh.ez")
    |> response(401)
  end
end
