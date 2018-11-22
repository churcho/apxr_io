defmodule ApxrIo.Accounts.AuditLogTest do
  use ApxrIo.DataCase, async: true

  alias ApxrIo.Accounts.AuditLog

  setup do
    user = build(:user, id: 1)
    project = build(:project, id: 2)
    release = build(:release, id: 3)
    %{user: user, project: project, release: release}
  end

  describe "build/4" do
    test "action owner.add", %{user: user, project: project} do
      audit = AuditLog.build(user, "user_agent", "0.0.0.0", "owner.add", {project, "full", user})

      assert audit.action == "owner.add"
      assert audit.user_id == user.id
      assert audit.user_agent == "user_agent"
      assert audit.params.level == "full"
      assert audit.params.project.id == project.id
      assert audit.params.project.name == project.name
      assert audit.params.project.meta.description == project.meta.description
      assert audit.params.user.id == user.id
      assert audit.params.user.username == user.username
    end
  end

  describe "audit/4" do
    test "with params", %{user: user, project: project, release: release} do
      multi =
        AuditLog.audit(
          Ecto.Multi.new(),
          {user, "user_agent", "0.0.0.0"},
          "release.publish",
          {project, release}
        )

      assert {:insert, changeset, []} = Ecto.Multi.to_list(multi)[:"log.release.publish"]
      assert changeset.valid?
    end

    test "with fun", %{user: user} do
      multi =
        AuditLog.audit(
          Ecto.Multi.new(),
          {user, "user_agent", "0.0.0.0"},
          "key.generate",
          fn %{} ->
            build(:key)
          end
        )

      assert {:merge, merge} = Ecto.Multi.to_list(multi)[:merge]
      multi = merge.(multi)
      assert {:insert, changeset, []} = Ecto.Multi.to_list(multi)[:"log.key.generate"]
      assert changeset.valid?
    end
  end

  describe "audit_with_user/4" do
    test "action user.create" do
      fun = fn %{user: user} -> user end

      multi =
        AuditLog.audit_with_user(
          Ecto.Multi.new(),
          {nil, "user_agent", "0.0.0.0"},
          "user.create",
          fun
        )

      assert {_, fun} = Ecto.Multi.to_list(multi)[:"log.user.create"]
    end
  end

  describe "audit_many/5" do
    test "action key.remove", %{user: user} do
      keys = build_list(2, :key)

      multi =
        AuditLog.audit_many(Ecto.Multi.new(), {user, "user_agent", "0.0.0.0"}, "key.remove", keys)

      assert {:insert_all, AuditLog, [params1, params2], []} =
               Ecto.Multi.to_list(multi)[:"log.key.remove"]

      assert params1.action == "key.remove"
      assert params1.user_id == user.id
      assert params2.action == "key.remove"
      assert params2.user_id == user.id
    end
  end
end
