defmodule ApxrIoWeb.PolicyControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  test "show policy privacy" do
    conn =
      build_conn()
      |> get("policies/privacy")

    assert response(conn, 200) =~ "Privacy Policy"
  end

  test "show policy terms of services" do
    conn =
      build_conn()
      |> get("policies/terms-of-use")

    assert response(conn, 200) =~ "Terms of Use"
  end
end
