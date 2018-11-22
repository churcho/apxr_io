defmodule ApxrIoWeb.PlugParserTest do
  use ApxrIoWeb.ConnCase

  describe "erlang media request" do
    test "POST /api/users" do
      params = %{
        username: Fake.sequence(:username),
        email: Fake.sequence(:email)
      }

      erlang_params = ApxrIoWeb.ErlangFormat.encode_to_iodata!(params)

      build_conn()
      |> put_req_header("content-type", "application/vnd.apxrsh+erlang")
      |> post("api/users", erlang_params)
      |> json_response(201)

      assert ApxrIo.Repo.get_by!(ApxrIo.Accounts.User, username: params.username)
    end
  end
end
