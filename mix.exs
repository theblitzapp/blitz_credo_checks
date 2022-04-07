defmodule BlitzCredoChecks.MixProject do
  use Mix.Project

  def project do
    [
      app: :blitz_credo_checks,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix, :credo],
        list_unused_filters: true,
        plt_local_path: "dialyzer",
        plt_core_path: "dialyzer",
        flags: [:unmatched_returns]
      ],
      preferred_cli_env: [
        credo: :test,
        dialyzer: :test,
        check: :test,
        doctor: :test,
        ex_doc: :test,
        coveralls: :test,
        "coveralls.json": :test,
        "coveralls.html": :test
      ],
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
      {:ex_check, "~> 0.12", only: :test, runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :test, runtime: false},
      {:excoveralls, "~> 0.13", only: :test, runtime: false},
      {:ex_doc, "~> 0.26", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.18.0", only: :test}
    ]
  end
end
