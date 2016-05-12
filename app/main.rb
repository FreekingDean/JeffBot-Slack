$stdout.sync = true
require 'slack-ruby-client'
require 'timeout'
require 'awesome_print'
require_relative 'lib/mqwrapper'

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

client = Slack::RealTime::Client.new
base_client = Slack::Web::Client.new

channel = "religouscirclejerk"

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  puts "RCD"
  begin
    outgoing = false
    begin
      if base_client.channels_info(channel: data.channel).channel.name == channel
        outgoing = true
      end
    rescue Slack::Web::Api::Error => ex
      ap ex
      outgoing = false
    end

    Timeout::timeout(2) do
      message = MQWrapper.send(data.text)
      if outgoing
        ap "Sending #{message} at #{Time.now} because: "
        ap data
        client.message channel: data.channel, text: message
      end
    end
  rescue StandardError => ex
    ap ex
    client.message channel: "##{channel}", text: "ERROR - I dun got fucked: #{ex}"
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
