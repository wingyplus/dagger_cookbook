defmodule PhoenixCi.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_ci,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dagger, github: "dagger/dagger", sparse: "sdk/elixir"},
      {:dagger_compose, path: "~/src/github.com/wingyplus/dagger_compose"}
    ]
  end
end
