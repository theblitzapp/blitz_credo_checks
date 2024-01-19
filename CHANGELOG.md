# Changelog

## Unreleased

## v0.1.10 (2024-01-19)

- Fix `DocsBeforeSpecs` to handle specs on `defp` functions.

## v0.1.9 (2023-11-28)

- De-duplicate `TodosNeedTickets`
- Update Elixir and OTP versions
- Use single file for CI
- Add auto merge for Dependabot updates

## v0.1.8 (2023-05-01)

- Don't enforce concurrency when dropping indexes

## v0.1.7 (2022-09-26)

- Fix for `UseStreamTest` where it had a false positive on adjacent Enum functions that were not piped into each other

## v0.1.6 (2022-06-28)

- allowed_modules option for `ImproperImport` can now take a list of atoms as well as a list of lists
- Add `:consecutive_lines` option to `UseStream`
- Add `ConcurrentIndexMigrations` check

## v0.1.5 (2022-05-26)

- Make Credo available for prod build to resolve OTP 25 errors on release
- Update OTP/Elixir versions
- Minor dependency updates

## v0.1.4 (2022-04-25)

- Fix CI checks names
- Enforce that indentation is at least 4 characters in `DoctestIndent`

## v0.1.3 (2022-04-12)

- Fix print statements not showing in console for credo_diff errors

## v0.1.2 (2022-04-12)

- Added check
  - `TodoNeedsTickets`

## v0.1.1 (2022-04-11)

- Added CredoDiff task that runs Credo on files that have changed from trunk
- Added checks
  - `ImproperImport`
  - `NoRampantRepos`

## v0.1.0 (2022-04-08)

- Added checks
  - `DocsBeforeSpecs`
  - `DoctestIndent`
  - `LowercaseTestNames`
  - `NoAsyncFalse`
  - `NoDSLParentheses`
  - `NoIsBitstring`
  - `SetWarningsAsErrorsInTest`
  - `StrictComparison`
  - `UseStream`
- General documentation and tooling

## Created Repo (2022-04-07)

- Created the project!
