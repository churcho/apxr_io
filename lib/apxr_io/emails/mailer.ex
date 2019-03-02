defmodule ApxrIo.Emails.Mailer do
  use Bamboo.Mailer, otp_app: :apxr_io

  def deliver_now_throttled(email) do
    ses_rate = ses_rate()

    email
    |> recipients()
    |> recipient_chunks(ses_rate)
    |> Enum.each(fn chunk ->
      ApxrIo.Throttle.wait(ApxrIo.SESThrottle, length(chunk))

      email
      |> Bamboo.Email.to(chunk)
      |> deliver_now()
    end)
  end

  defp recipient_chunks(recipients, :infinity) do
    [recipients]
  end

  defp recipient_chunks(recipients, limit) do
    Enum.chunk_every(recipients, limit)
  end

  defp recipients(email) do
    email
    |> Bamboo.Mailer.normalize_addresses()
    |> Bamboo.Email.all_recipients()
  end

  defp ses_rate() do
    if rate = Application.get_env(:apxr_io, :ses_rate) do
      rate
    else
      :infinity
    end
  end
end
