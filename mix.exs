defmodule TwinkleStar.MixProject do
  use Mix.Project

  def project do
    [
      app: :twinkle_star,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :hackney]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tree_magic, git: "https://github.com/antoniskalou/tree_magic.ex"},
      {:hackney, "~> 1.15", optional: true}
    ]
  end
end
