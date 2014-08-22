tester
======

Test runner for unix files.

## Set-Up

Add a directory called `test` to your project.

## Writing Tests

Tests can be written in any interpreted language, so long as the file can be called directly (i.e. `./my_test`). This is often done by adding a shebang to the top of the file.

Tests can have any name, except "before" or "after"

## Contexts

Similar tests can be grouped into contexts, by placing them into a directory. Contexts can be placed into contexts.

### Hooks: before and after

The `before` file (if present) is guaranteed to run before any tests or contexts. If it fails, the tests and contexts within the context will not be run.

The `after` file (if present) will be run after tests, often to clean up artifacts resulting from tests being run.

## Test Results

### Reporting

The test result is determined by the exitcode of the test.

* 0 => Pass
* 1 => Fail
* 2 => Skip

Any other returncodes are currently reported as failing, though this is subject to change.

### Appearance when run

When run on the console, characters will appear corresponding to the status of the test.

* Pass => . (green if colors are enabled)
* Fail => F (red if colors are enabled)
* Skip => * (yellow if colors are enabled)

If a test fails to run, either because it is not executable, or because the before fails, the character will be a `?`

Support for custom formatters will be added in the future.

