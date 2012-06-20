#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'uri'
require 'yaml'
require 'net/http'
require 'nokogiri'

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

        @@Res_nb_regex = /Notices?\s(\d+)\s+sur\s+(\d+)/i
        @@No_result_regex = /<h\d>Aucun résultat trouvé<h\d>/i

        def initialize(http_resp)
            @html = http_resp.body
            @noko = Nokogiri::HTML(@html)
        end

        def parse()
            return [] if @@No_result_regex.match(@html).nil?

            res_nb, res_total = @@Res_nb_regex.match(@html).captures.map(&to_i)
        end

        def to_html
            @html
        end

        def to_nokogiri
            @noko
        end

        private

        def _parse_book(html)

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
            SearchEngine::query(self.to_url)
        end
    end

end

# TODO
#
# add headers, like Referer, User-Agent, etc
#
