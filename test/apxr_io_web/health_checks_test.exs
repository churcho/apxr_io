defmodule ApxrIoWeb.HealthChecksTest do
  use ApxrIoWeb.ConnCase, async: true

  describe "health_checks" do
    test "/health" do
      insert(:user, id: 1)

      build_conn()
      |> get("health")
      |> json_response(200)
    end
  end
end
