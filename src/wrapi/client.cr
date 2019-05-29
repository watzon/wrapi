require "logger"
require "halite"

module Wrapi
  class Client
    setter logger : Logger

    setter http : Halite::Client

    # Get the logger instance
    def logger
      @@logger ||= Logger.new(STDOUT)
    end

    def http
      @@http ||= Halite::Client.new(
        endpoint: Wrapi::Config.base_endpoint,
        headers: Wrapi::Config.make_headers,
        cookies: Wrapi::Config.cookies,
        params: Wrapi::Config.params,
        form: Wrapi::Config.form_data,
        json: Wrapi::Config.json_data,
        raw: Wrapi::Config.raw_data,
        tls: Wrapi::Config.tls,
        timeout: Wrapi::Config.timeout,
        follow: Wrapi::Config.follow_redirects,
              # proxy: Wrapi::Config.proxy,
)
    end

    def wrapi_get(path, options)
    end

    def wrapi_post(path, options)
    end

    def wrapi_put(path, options)
    end

    def wrapi_patch(path, options)
    end

    def wrapi_delete(path, options)
    end

    def wrapi_request(path, options)
    end

    def wrapi_paginate(path, options)
    end

    def wrapi_assert(key, message = nil)
    end

    class WrapiPaginator(T)
    end
  end
end
