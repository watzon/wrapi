require "logger"
require "halite"

module Wrapi
  class Client
    setter http : Halite::Client?

    # Get the logger instance
    def logger
      Wrapi::Config.logger
    end

    def http
      @@http ||= Halite::Client.new
      # endpoint: Wrapi::Config.base_endpoint,
      # headers: Wrapi::Config.make_headers,
      # cookies: Wrapi::Config.cookies,
      # params: Wrapi::Config.params,
      # form: Wrapi::Config.form_data,
      # json: Wrapi::Config.json_data,
      # raw: Wrapi::Config.raw_data,
      # tls: Wrapi::Config.tls,
      # timeout: Wrapi::Config.timeout,
      # follow: Wrapi::Config.follow_redirects,
      # proxy: Wrapi::Config.proxy,
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

    def wrapi_assert(key, message = nil, fatal = true)
      key = key.to_s
      message ||= "Assertion for :#{key} failed"
      assertion = Wrapi::Config.assertions[key]?
      if assert = assertion
        result = assert.call
        raise message
        Wrapi::Config.logger.error(message)
      else
        Wrapi::Config.logger.warn("No assertion for key '#{key}'")
      end
    end

    class WrapiPaginator(T)
    end
  end
end
