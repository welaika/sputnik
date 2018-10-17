defmodule Sputnik.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sputnik,
      version: "0.2.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      escript: [main_module: Sputnik],
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      name: "Sputnik",
      source_url: "https://github.com/spawnfest/sputnik",
      description: "Sputnik is a website crawler written in Elixir.",
      package: [
        name: "sputnik",
        maintainers: ["Filippo Gangi Dino", "Riccardo Magliocchetti", "Fabrizio Monti", "Stefano Pau"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/welaika/sputnik"}
      ],
      homepage_url: "https://dev.welaika.com",
      docs: [
        main: "Sputnik", # The main page in the docs
        logo: "static/sputnik_logo_w.png",
        extras: ["README.md"]
      ]
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
      {:httpoison, "~> 0.13.0"},
      {:floki, "~> 0.19.1"},
      {:poison, "~> 4.0"},
      {:excoveralls, "~> 0.7", only: :test},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
