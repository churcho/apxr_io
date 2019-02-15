defmodule LoggerErrorMail do
  @behaviour :gen_event

  alias ApxrIo.Emails

  @default_format "$time $metadata[$level] $message\n"

  def init(_) do
    {:ok, configure([])}
  end

  def handle_call({:configure, opts}, _state) do
    {:ok, :ok, configure(opts)}
  end

  def handle_event({:error, _gl, {Logger, msg, ts, md}}, state) do
    log_event(msg, ts, md, state)
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  # helpers

  defp log_event(msg, ts, md, state) do
    msg = format_event(msg, ts, md, state)

    Emails.error_notification(msg)
    |> Emails.Mailer.deliver_later()
  end

  defp format_event(msg, ts, _md, %{format: format}) do
    Logger.Formatter.format(format, :error, msg, ts, [])
    |> IO.iodata_to_binary()
  end

  defp configure(opts) do
    format_opts = Keyword.get(opts, :format, @default_format)
    format = Logger.Formatter.compile(format_opts)
    %{format: format}
  end
end
