#!/usr/bin/env ruby

require './tweecle'

tweecle = Tweecle.new("config.yaml" , STDOUT)

while true
  begin
    tweecle.crawl(:list_statuses , 'basyura' , 'all')
    tweecle.crawl(:replies)
    #tweecle.crawl(:search , '#llplanets')
    sleep 30
  rescue => e
    puts e
    sleep 5
  end
end

