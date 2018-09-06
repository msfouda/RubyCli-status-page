# StatusPage

## Installation Local

to user Locally within it's directory

```sh
bundle install
```

to use it from anywhere

```sh
rake install
```

## Usage

```sh
status-page hello yourname

status-page pull

status-page live

status-page history

status-page backup <Path for history backup>

status-page restore <Path for history restore file>

status-page add <Server name> <Server API>

status-page delete <Server name>
```

## Installation After Release

Add this line to your application's Gemfile:

```sh
gem "status-page"
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install status-page
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
