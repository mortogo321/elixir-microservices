defmodule Auth.MixProject do
  use Mix.Project

  def project do
    [
      app: :auth,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Auth.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Shared library
      {:shared, path: "../shared"},

      # gRPC (1.x split: :grpc = client/Stubs, :grpc_server = server).
      # Auth runs the server but the generated auth.pb.ex also defines the
      # client Stub, so both packages are required at compile time.
      {:grpc, "~> 1.0"},
      {:grpc_server, "~> 1.0"},
      {:protobuf, "~> 0.14"},

      # Database
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.21"},

      # Auth
      {:bcrypt_elixir, "~> 3.0"},
      {:jose, "~> 1.11"},

      # Message Queue
      {:amqp, "~> 4.0"},

      # Utils
      {:jason, "~> 1.4"},

      # Dev/Test
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
