use Mix.Config

config :logger,
  level: :debug,
  utc_log: true

config :logger, :console,
  level: :debug,
  format: "$dateT$time [$level] $message\n"
