require 'redis'

module Sinatra
  module PubSub
    module Redis extend self
      def subscribe
        redis = ::Redis.connect

        redis.psubscribe('pubsub', 'pubsub.*') do |on|
          on.pmessage do |match, channel, message|
            channel = channel.sub(/\Apubsub\.?/, '')
            channel = channel.empty? ? :all : channel.to_sym
            Stream.publish(channel, message)
          end
        end
      end

      def publish(channels, message)
        redis = ::Redis.connect
        Array(channels).uniq.each do |c|
          redis.publish("pubsub.#{c}", message)
        end
      end

      def publish_all(message)
        publish(:all, message)
      end
    end
  end
end
