# Crystal Stdio

A small library for capturing stdios written in Crystal.

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

out, err = Stdio.capture do |io|
  STDOUT.puts ":)"
  STDERR.puts ":("
  [io.out.gets, io.err.gets]
end

puts out # prints ":)"
puts err # prints ":("
```

## Development

[WIP]

## Contributing

1. Fork it ( https://github.com/mosop/stdio/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mosop](https://github.com/mosop) - creator, maintainer
