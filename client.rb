#!/usr/bin/env ruby

require './tweecle'

Tweecle.new("config.yaml" , STDOUT).crawl(30) do
  replies
  list_statuses 'basyura' , 'all'
end
