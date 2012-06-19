#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require './search'

s = BUP7::Search.new
s.params { |p|
    p[:libraries] = :all
    p[:keywords] = ['foo']
    p[:keywords_types] = [:title]
}
puts s.encode.inspect

puts s.send.inspect
