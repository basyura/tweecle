#!/usr/bin/env ruby

require './tweecle'

Tweecle.new("config.yaml" , STDOUT).crawl(30) do
  list_statuses 'basyura' , 'all'
  replies
#  search '#llplanets'
end
