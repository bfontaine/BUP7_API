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

class BUP7

    class Book

    end

    class SearchResult
        def initialize(http_resp)
            @html = http_resp.body
        end

        def parse()

        end

        def to_html
            @html
        end
    end

    class SearchEngine
        def SearchEngine::query(q)
            uri = URI(CONFIG[:url] + q)
            headers = CONFIG[:headers]

            http = Net::HTTP.new(uri.host, uri.port)

            req = Net::HTTP::Get.new(uri.request_uri)
            headers.each do |k,v|
                req.add_field(k.to_s, v.to_s)
            end

            resp = http.start do |h|
                h.request(req)
            end

            SearchResult.new(resp)
        end
    end

    class SearchQuery
        def send()
            SearchEngine::query(self.to_s)
        end
    end

end

# TODO
#
# add headers, like Referer, User-Agent, etc
#
