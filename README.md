# BlitzCredoChecks

[![Build Status](https://github.com/theblitzapp/blitz_credo_checks/workflows/Coveralls/badge.svg)](https://github.com/theblitzapp/blitz_credo_checks) [![Build Status](https://github.com/theblitzapp/blitz_credo_checks/workflows/Dialyzer/badge.svg)](https://github.com/theblitzapp/blitz_credo_checks) [![Build Status](https://github.com/theblitzapp/blitz_credo_checks/workflows/Credo/badge.svg)](https://github.com/theblitzapp/blitz_credo_checks)  [![Build Status](https://github.com/theblitzapp/blitz_credo_checks/workflows/Doctor/badge.svg)](https://github.com/theblitzapp/blitz_credo_checks) [![codecov](https://codecov.io/gh/theblitzapp/blitz_credo_checks/branch/master/graph/badge.svg?token=P3O42SF7VJ)](https://codecov.io/gh/theblitzapp/blitz_credo_checks) [![hex.pm](http://img.shields.io/hexpm/v/blitz_credo_checks.svg?style=flat)](https://hex.pm/packages/blitz_credo_checks)

A set up custom checks used by the Blitz backend Elixir team on top of the excellent ones included with [Credo](https://github.com/rrrene/credo). We use these checks to catch errors, improve code quality, maintain consistency, and shorten pull request review times.

Check the moduledocs inside the check modules themselves for details on the individual checks.

## Using these checks

### 1. Add dependencies

Add Credo (required to run the checks) and BlitzCredoChecks to your project dependencies by adding the following to your `mix.exs`

```elixir
defp deps do
  [
    {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
    {:blitz_credo_checks, "~> 0.1", only: [:dev, :test], runtime: false}
  ]
end
```

### 2. Create configuration file

If you do not have one already in the root of your project, a default Credo configuration file `.credo.exs` can be generated with

```bash
mix credo.gen.config
```

### 3. Add these checks

Add some or all of these checks under the checks key in `.credo.exs`

```elixir
      checks: [
        # Custom checks
        {BlitzCredoChecks.DocsBeforeSpecs, []},
        {BlitzCredoChecks.DoctestIndent, []},
        {BlitzCredoChecks.LowercaseTestNames, []},
        {BlitzCredoChecks.NoAsyncFalse, []},
        {BlitzCredoChecks.NoDSLParentheses, []},
        {BlitzCredoChecks.NoIsBitstring, []},
        {BlitzCredoChecks.SetWarningsAsErrorsInTest, []},
        {BlitzCredoChecks.StrictComparison, []},
        {BlitzCredoChecks.UseStream, []},
        
        # ... all the other checks that come with Credo
      ]
```

### 4. Run Credo

```bash
mix credo
```

## Contributing

We welcome contributions to this library. Bear in mind however that new checks can be very controversial as they have a large impact on developer experience. We therefore recommend that you open an issue to discuss a new check before beginning work on a new one.

### Getting set up locally

1. Consider opening an issue for discussion
2. Fork and clone this repository on GitHub
3. Install elixir and erlang versions with `asdf`

```bash
asdf install
```

4. Fetch dependencies

```bash
mix deps.get
```

5. Run the test suite

```bash
mix check
```

6. Use your work in another project

It is an excellent idea to not just write tests, but to also run your check against another codebase.

Include your cloned project under `deps` in the `mix.exs` of your other codebase

```elixir
{:blitz_credo_checks, path: "/home/username/dev/blitz_credo_checks/"}
```

And fetch your dependencies to pull in the local version you are working on

```bash
mix deps.get
```
