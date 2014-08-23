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

Any other returncodes will report as an error.

### Appearance when run

When run on the console using the default formatter, characters will appear corresponding to the status of the test.

* Pass => . (green if colors are enabled)
* Fail => F (red if colors are enabled)
* Skip => * (yellow if colors are enabled)

If a test fails to run, either because it is not executable, or because the before fails, the character will be a `?`

# Result Formatting

It is possible to define a custom formatter by adding a file to the formatters directory

```ruby
Tester::Formatter.define_format "standard", inline: true do
  pass   ".", color: :green
  fail   "F", color: :red
  skip   "*", color: :yellow
  ignore "?", color: :default
end
```

The options for colors are red, cyan, yellow, red, green, magenta, blue, and default (which is the same as no color).

The `inline` option specifies that the results are to be placed on the same line. It defaults to true.

It is also possible to pass it a block with the test as an argument, allowing for more complex result formatting.

```ruby
pass color: :green do |test|
  "#{test.name} passed with flying colors!"
end
```

The formatter can then be used by adding the flag `--format formatter_name`


