# BlitzCredoChecks

[![Build Status](https://github.com/theblitzapp/blitz_credo_checks/workflows/Coveralls/badge.svg)](https://github.com/theblitzapp/blitz_credo_checks) [![Build Status](https://github.com/theblitzapp/blitz_credo_checks/workflows/Dialyzer/badge.svg)](https://github.com/theblitzapp/blitz_credo_checks) [![Build Status](https://github.com/theblitzapp/blitz_credo_checks/workflows/Credo/badge.svg)](https://github.com/theblitzapp/blitz_credo_checks)  [![Build Status](https://github.com/theblitzapp/blitz_credo_checks/workflows/Doctor/badge.svg)](https://github.com/theblitzapp/blitz_credo_checks) [![codecov](https://codecov.io/gh/theblitzapp/blitz_credo_checks/branch/master/graph/badge.svg?token=P3O42SF7VJ)](https://codecov.io/gh/theblitzapp/blitz_credo_checks) [![hex.pm](http://img.shields.io/hexpm/v/blitz_credo_checks.svg?style=flat)](https://hex.pm/packages/blitz_credo_checks)

## Using these checks

### 1. Add Credo and BlitzCredoChecks to your project

[Credo](https://github.com/rrrene/credo) is an excellent static analysis tool that is required to run these checks.

```elixir
defp deps do
  [
    {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
    {:blitz_credo_checks, "~> 0.1", only: [:dev, :test], runtime: false}
  ]
end
```

### 2. Create a Credo configuration file

If you do not have one already in the root of your project, and default Credo configuration file can be generated

```bash
mix credo.gen.config
```

### 3. Add this library's checks to the Credo configuration file

Add some or all of the checks under the checks key.

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
