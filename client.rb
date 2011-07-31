#!/usr/bin/env ruby

require './tweecle'

tweecle = Tweecle.new("config.yaml")

while true
  begin
    tweecle.crawl(:list_statuses , 'basyura' , 'all')
    tweecle.crawl(:replies)
    sleep 30
  rescue => e
    puts e
    sleep 5
  end
end

