$stdout.sync = true
require 'slack-ruby-client'
require 'timeout'
require 'awesome_print'
require_relative 'lib/mqwrapper'

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

client = Slack::RealTime::Client.new

channel = ENV['RESPONSE_CHANNEL']

def get_channel(channel_name)
  Slack::Web::Client.new.channels_info(channel: data.channel).channel.name
rescue Slack::Web::Api::Error => ex
  ap ex
  ''
end

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  ap data
  next if data.has_key?('subtype')

  begin

    Timeout::timeout(5) do
      message = MQWrapper.send(data.text)
      if get_channel(data.channel) == channel
        client.message channel: data.channel, text: message
      end
    end
  rescue StandardError => ex
    ap "ERROR - I dun got fucked: #{ex}"
  end
end

client.on :close do |_data|
  ap _data
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  ap _data
  puts "Client has disconnected successfully!"
end

client.start!

