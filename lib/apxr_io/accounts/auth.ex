defmodule ApxrIo.Accounts.Auth do
  import Ecto.Query, only: [from: 2]

  alias ApxrIo.Accounts.{Key, Keys, User, Users}

  # token is valid for 30 minutes / 1800 seconds
  @token_max_age 1800

  def gen_token(nil), do: {:error, :not_found}

  def gen_token(email_address) when is_binary(email_address) do
    user = Users.get(email_address, [:emails])
    email = find_email(user, email_address)

    if email do
      create_and_send_token(user, email)
    else
      {:error, :email_not_found}
    end
  end

  def token_auth(nil), do: {:error, :invalid}

  def token_auth(auth_token) do
    user = Users.get_by_token(auth_token, [:owned_projects, :emails, :teams])

    if user do
      user_id = user.id

      case Phoenix.Token.verify(ApxrIoWeb.Endpoint, "user", auth_token, max_age: @token_max_age) do
        {:ok, ^user_id} ->
          clear_token(user)

          {:ok,
           %{
             key: nil,
             user: user,
             team: nil,
             email: find_email(user, nil),
             source: :auth_token
           }}

        # reason can be :invalid or :expired
        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :not_found}
    end
  end

  def gen_key() do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
  end

  def key_auth(user_secret, usage_info) do
    # Database index lookup on the first part of the key and then
    # secure compare on the second part to avoid timing attacks
    app_secret = Application.get_env(:apxr_io, :secret)

    <<first::binary-size(32), second::binary-size(32)>> =
      :crypto.hmac(:sha256, app_secret, user_secret)
      |> Base.encode16(case: :lower)

    result =
      from(
        k in Key,
        where: k.secret_first == ^first,
        left_join: u in assoc(k, :user),
        left_join: o in assoc(k, :team),
        left_join: a in assoc(k, :artifact),
        preload: [user: {u, [:owned_projects, :emails, :teams]}],
        preload: [team: o],
        preload: [artifact: a]
      )
      |> ApxrIo.Repo.one()

    case result do
      nil ->
        :error

      key ->
        if ApxrIo.Utils.secure_check(key.secret_second, second) do
          if Key.revoked?(key) do
            :revoked
          else
            Keys.update_last_use(key, usage_info(usage_info))

            {:ok,
             %{
               key: key,
               user: key.user,
               team: key.team,
               artifact: key.artifact,
               email: find_email(key.user, nil),
               source: :key
             }}
          end
        else
          :error
        end
    end
  end

  defp create_and_send_token(user, email) do
    user
    |> create_token()
    |> ApxrIo.Emails.login_link(user, email)
    |> ApxrIo.Emails.Mailer.deliver_now_throttled()

    :ok
  end

  defp create_token(user) do
    auth_token = Phoenix.Token.sign(ApxrIoWeb.Endpoint, "user", user.id, max_age: @token_max_age)

    User.update_auth_token(user, %{auth_token: auth_token})
    |> ApxrIo.Repo.update!()

    auth_token
  end

  defp clear_token(user) do
    User.update_auth_token(user, %{auth_token: nil})
    |> ApxrIo.Repo.update!()
  end

  defp find_email(nil, _email) do
    nil
  end

  defp find_email(user, email) do
    Enum.find(user.emails, &(&1.email == email)) || Enum.find(user.emails, & &1.primary)
  end

  defp usage_info(info) do
    %{
      ip: parse_ip(info[:ip]),
      used_at: info[:used_at],
      user_agent: parse_user_agent(info[:user_agent])
    }
  end

  defp parse_ip(nil), do: nil

  defp parse_ip(ip_tuple) do
    ip_tuple
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp parse_user_agent(nil), do: nil
  defp parse_user_agent([]), do: nil
  defp parse_user_agent([value | _]), do: value
end
