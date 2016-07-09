# Crystal Stdio

A small Crystal library for capturing standard I/O streams.

[![Build Status](https://travis-ci.org/mosop/stdio.svg?branch=master)](https://travis-ci.org/mosop/stdio)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  stdio:
    github: mosop/stdio
```

## Usage

```crystal
require "stdio"

out, err, in = Stdio.capture do |io|
  STDOUT.puts ":)"
  STDERR.puts ":("
  io.in.puts ":P"
  [io.out.gets, io.err.gets, STDIN.gets]
end

puts out # prints ":)"
puts err # prints ":("
puts in  # prints ":P"
```

## Decapturing

The `out` and `err` methods returns *decaptured* I/Os. The type of the I/O means that the I/O is not capturing the standard stream any more. In other words, you can not capture the standard streams any more in the same yielded block after calling `out` or `err`.

```crystal
Stdio.capture do |io|
  STDOUT.puts ":)" # captured
  io.out.gets # decaptured and taken ":)\n"
  STDOUT.puts ":X" # prints ":X", not captured
end
```

Why should I/Os be decaptured? Because a process easily hangs up when you send any waiting methods to the I/Os that are not decaptured.

To access I/Os keeping capturing and control waiting by yourself, use the `out!` and `err!` methods.

```crystal
Stdio.capture do |io|
  STDOUT.puts ":)"
  io.out!.gets # => ":)\n"
  STDOUT.puts ":X"
  io.out!.gets # => ":X\n"
  io.out!.gets # waits
end
```

## Release Notes

* v0.1.3
  * Capture#out!, Capture#err!
* v0.1.2
  * STDIN

## Contributing

1. Fork it ( https://github.com/mosop/stdio/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mosop](https://github.com/mosop) - creator, maintainer
