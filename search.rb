#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'uri'
require 'yaml'
require 'net/http'

CONFIG = begin
             YAML.load(File.read('url_params.yaml'))
         rescue Errno::ENOENT
             {}
         end

require_relative './query'

# TODO
#
# add headers, like Referer, User-Agent, etc
#
