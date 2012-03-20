#!/usr/bin/env ruby

require './tweecle'

=begin
config = {
  :consumer_key        => '....',
  :consumer_secret     => '....',
  :access_token        => '....',
  :access_token_secret => '....',
}
=end

config = YAML.load(open('./config.yaml').read)

Tweecle.new(config).crawl(30) do
  replies
  list_statuses 'basyura', 'all'
  search 'tweetvim'
end
