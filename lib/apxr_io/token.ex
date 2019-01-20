defmodule ApxrIo.Token do
  use Joken.Config

  def token_config do
    default_claims(
      iss: "apxr_io",
      aud: "apxr_run",
      default_exp: 60 * 60 # 1 hour
    )
  end
end
