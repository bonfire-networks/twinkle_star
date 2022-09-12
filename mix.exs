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
      {:file_info, "~> 0.0.4"},
      {:tree_magic,
       git: "https://github.com/bonfire-networks/tree_magic.ex", optional: true},
      {:hackney, "~> 1.15", optional: true}
    ]
  end
end
