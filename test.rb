#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require './search'

s = BUP7::SearchQuery.new('foo').for(:all).between(1914, 2012).in(:all)

r = s.send
p r.to_html
