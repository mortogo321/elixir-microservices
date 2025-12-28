defmodule Alert.MixProject do
  use Mix.Project

  def project do
    [
      app: :alert,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        alert: [
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Alert.Application, []}
    ]
  end

  defp deps do
    [
      {:shared, path: "../shared"},
      {:amqp, "~> 3.3"},
      {:jason, "~> 1.4"},
      {:swoosh, "~> 1.16"},
      {:gen_smtp, "~> 1.2"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
