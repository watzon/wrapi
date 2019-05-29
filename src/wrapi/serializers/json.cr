require "json"

module Wrapi
  module Serializers
    class JSON < Wrapi::Serializer
      alias CJSON = Crystal::JSON

      def self.serialize(entity : Wrapi::Entity)
      end

      def self.deserialize(raw : String)
      end
    end
  end
end
