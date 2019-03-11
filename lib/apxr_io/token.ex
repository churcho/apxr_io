defmodule ApxrIo.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(
      default_exp: 60 * 60,
      skip: [:iss, :aud]
    )
    |> add_claim("aud", nil, &(&1 in ["apxr_io", "apxr_run"]))
    |> add_claim("iss", nil, &(&1 in ["apxr_io", "apxr_run"]))
  end
end
