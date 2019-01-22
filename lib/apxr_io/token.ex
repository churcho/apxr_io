defmodule ApxrIo.Token do
  use Joken.Config

  def token_config do
    default_claims(
      iss: "apxr_io",
      aud: "apxr_run",
      # 1 hour
      default_exp: 60 * 60
    )
  end
end
