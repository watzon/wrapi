# Wrapi

Wrapi is a framework that gives structure and uniformity to the writing of REST API wrappers. Rather than having to define your own client, create deserialization objects, manually manage headers, paginate responses, etc. etc. you can instead extend Wrapi and make your developent process faster, your code cleaner, and yourself happier.

Keep in mind that none of the documented features work yet. This is a work in progress.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wrapi:
       github: watzon/wrapi
   ```

2. Run `shards install`

Shards will place a `wrapi` executable in your `bin` directory which can be used to scaffold a project and generate useful boilerplate code.

### CLI

The CLI is the easiest way to generate the boilerplate code for a new project. To run it, make sure you've run `shards install` and then run the `wrapi` executable in the `bin` directory.

```shell
./bin/wrapi init
```

The `init` command will generate a configuration file for you at `src/wrapi_config.cr`.

```crystal
Wrapi::Settings.configure do |config|

  # Set the User-Agent header  
  config.user_agent = "Wrapi (crystal lib) - #{Wrapi::VERSION}"

  # Headers can also be set manually. These will be merged with other
  # options that change headers, with these values taing presidence.
  config.headers = {"Accept" => "application/vnd.github.v3+json"}

  config.add_endpoint :default, root: "https://api.github.com"

end
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/watzon/wrapi/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Watson](https://github.com/watzon) - creator and maintainer
