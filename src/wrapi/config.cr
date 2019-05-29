require "halite"
require "./logger"
# require "./client"
require "./entity"

module Wrapi
  # Wrapi Configuration Module
  #
  # `Wrapi::Config` is the main entrypoint into the Wrapi framework,
  # as it allows you to fully configure your API wrapper. With it
  # you can configure existing settings, as well as define your
  # own custom settings which can be accessed elsewhere in
  # your appliction.
  #
  # ### Options
  #
  # ##### name : String
  # Will be used in the `Playground` as a title and in log
  # messages. (default: `"Wrapi App"`)
  #
  # ##### logger : `Wrapi::Logger`
  # Logger for the application. Default logger includes a
  # `Wrapi::Logger::ConsoleTransport`.
  #
  # ##### user_agent : String
  # Sets the User-Agent header for all requests.
  # (default: `"Wrapi (crystal lib) - #{Wrapi::VERSION}"`)
  #
  # ##### base_endpoint : String
  # Sets the base endpoint for all requests. All methods that make
  # a request will use this as a base unless the inputted URI
  # contains a protocol. (default: nil)
  #
  # ```
  # config.base_endpoint = "https://api.github.com"
  #
  # ...wapi_get("/user")                         # Will get `https://api.github.com/user`
  # wapi_get("https://graph.facebook.com/users") # Will not use the `base_endpoint`
  # ```
  #
  # ##### headers : Hash(String, _) | NamedTuple
  # Sets default headers for all requests. These will override other
  # header-setting methods, so tread carefully. (default: `nil`)
  #
  # ```
  # config.headers = {"Accept" => "application/vnd.github.v3+json"}
  # ```
  #
  # ##### cookies : Hash(String, _) | NamedTuple
  # Sets default cookies for all requests. (default: `nil`)
  #
  # ##### params : Hash(String, _) | NamedTuple
  # Sets default params for all requests. (default: `nil`)
  #
  # ##### form_data : Hash(String, _) | NamedTuple
  # Sets default form data for all requests. (default: `nil`)
  #
  # ##### json_data : Hash(String, _) | NamedTuple
  # Sets default json data for all requests. (default: `nil`)
  #
  # ##### raw_data : String
  # Sets default raw data for all requests. (default: `nil`)
  #
  # ##### tls : OpenSSL::SSL::Context::Client
  # Sets ssl information for the client. (default: `nil`)
  #
  # ##### connect_timeout : Int32 | Float64 | Time::Span
  # Sets how long we want to wait before giving up on connecting
  # to a server. (default: `nil`)
  #
  # ##### read_timeout : Int32 | Float64 | Time::Span
  # Sets how long we want to wait before giving up on reading. (default: `nil`)
  #
  # ##### max_redirects : Int32
  # Sets the maximum number of redirects we're willing to follow. (default: `0`)
  #
  # ##### auto_fetch : Bool
  # Sets whether or not to autofetch pages in a paginated response. (default: `false`)
  #
  # ##### auto_fetch_max : Int32
  # Sets the maximum number of pages to auto fetch. (default: `100`)
  #
  # ##### max_results : Int32
  # Sets the maximum number of results per page for paginated responses. (default: `100`)
  #
  # ### Custom Config
  #
  # Wrapi allows you to define custom configuration variables for your app using
  # the `define_custom` macro. Custom configuration values are stored in a
  # NamedTuple at `Wrapi::Config.custom`
  #
  # ```
  # config.define_custom login : String?
  # config.define_custom num_requests : Int32, default: 0
  # ```
  #
  # ### Hooks
  #
  # Wrapi also allows you to define custom hooks which run before and after certain
  # actions.
  #
  # ##### before_request
  # Run before every request.
  #
  # ```
  # before_request do |uri|
  #   unless options[:no_tls]
  #     uri.scheme = "https"
  #   end
  # end
  # ```
  #
  # ##### after_request
  # Runs after every request.
  #
  # ```
  # after_request do |uri, response|
  #   if response.status_code == 404
  #     logger.warn "#{uri.to_s} was not found"
  #   end
  # end
  # ```
  #
  # ##### before_serialize
  # Runs befefore a `Wrapi::Entity` is serialized into raw data.
  #
  # ```
  # before_serialize do |entity|
  #   logger.info "Serializing #{typeof(entity)}"
  # end
  # ```
  #
  # ##### after_serialize
  # Runs after a `Wrapi::Entity` is serialized into raw data.
  #
  # ```
  # after_serialize do |entity, raw|
  #   logger.info("Finished serializing #{typeof(entity)}")
  #   logger.silly(raw)
  # end
  # ```
  #
  # ##### before_deserialize
  # Runs befefore a response is transformed into a `Wrapi::Entity`.
  #
  # ```
  # before_deserialize do |response|
  #   logger.info "Deserializing response"
  # end
  # ```
  #
  # ##### after_deserialize
  # Runs after a response is transformed into a `Wrapi::Entity`.
  #
  # ```
  # after_deserialize do |entity|
  #   logger.info("Finished deserializing #{typeof(entity)}")
  # end
  # ```
  #
  # ### Assertions
  #
  # Sometimes you want to make sure that something is true before
  # performing an action. This could be valiading that certain
  # config variables have been set or any number of other
  # things. Assertions allow you to do that in a DRY
  # way, and keeps the assertions out of your
  # clients.
  #
  # ```
  # config.define_assertion(:authenticated,
  #   "You must authenticate before using this method")
  #   config.custom[:login]? && config.custom[:password]?
  # end
  # ```
  #
  # To use your assertions just call the `wrapi_assert` from your
  # clients and entities, or `Wrapi::Config.assert` from
  # anywhere else.
  #
  # ```
  # def get_user
  #   wrapi_assert(:authenticated)
  #   get("user")
  # end
  # ```
  #
  # If the assertion fails, a `Wrapi::Exception::AssertException` will be raised.
  # If you want want to instead log an error and allow the program to continue
  # running, set `fatal` to false in your assertion definition.
  #
  # ```
  # config.define_assertion(:max_requests, "You have made too many requests", fatal: false)
  #   config.custom[:num_requests] > 1000
  # end
  # ```
  module Config
    class_property logger : Wrapi::Logger = Wrapi::Logger.new

    class_property? user_agent : String?

    class_getter? headers : Hash(String, String)?

    class_getter? cookies : Hash(String, String)?

    class_getter? params : Hash(String, String)?

    class_getter? form_data : Hash(String, String)?

    class_getter? json_data : Hash(String, String)?

    class_getter? raw_data : String?

    class_property? tls : OpenSSL::SSL::Context::Client?

    class_property? connect_timeout : (Int32 | Float64 | Time::Span)?

    class_property? read_timeout : (Int32 | Float64 | Time::Span)?

    class_property max_redirects : Int32 = 0

    class_property auto_fetch : Bool = false

    class_property auto_fetch_max : Int32 = 100

    class_property max_results : Int32 = 100

    class_getter? before_request_hook : Proc(URI, URI)?

    class_getter? after_request_hook : Proc(URI, Halite::Response, Nil)?

    class_getter? before_serialize_hook : Proc(Wrapi::Entity, Wrapi::Entity)?

    class_getter? after_serialize_hook : Proc(Wrapi::Entity, String, Nil)?

    class_getter? before_deserialize_hook : Proc(Halite::Response, Halite::Response)?

    class_getter? after_deserialize_hook : Proc(Wrapi::Entity, Nil)?

    def self.configure(&block)
      yield self
    end

    macro define_custom(value, default = nil)

    end

    macro define_assertion(name, message = nil, fatal = true)

    end
  end
end
