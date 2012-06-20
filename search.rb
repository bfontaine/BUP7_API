#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'uri'
require 'yaml'
require 'net/http'
require 'nokogiri'

CONFIG = begin
             YAML.load(File.read('config.yaml'))
         rescue Errno::ENOENT
             {}
         end

require_relative './query'

class BUP7

    class Book
        def initialize(d)
            @attrs = {}
            self.set(d)
        end

        def set(k, v=nil)
            if (k.is_a? Hash)
                @attrs.update(k)
            else
                @attrs[k] = v
            end
        end

        def to_hash
            @attrs
        end

        def to_s
            @attrs.inspect
            #@attrs['title']
        end
    end

    class SearchResult #FIXME parsing methods

        @@Res_nb_regex = /Notices?\s(\d+)\s+sur\s+(\d+)/i
        @@No_result_regex = /<h\d>Aucun r.sultat trouv.<h\d>/i

        def initialize(http_resp)
            @html = http_resp.body
            @noko = Nokogiri::HTML(@html)
        end

        def parse()
            return [] if !@@No_result_regex.match(@html).nil?

            res_nb, res_total = @@Res_nb_regex.match(@html).captures.map(&:to_i)

            return [_parse_one_book(@noko.css('.outertable')[0])] if res_nb == 1
            
            # TODO multiple books
        end

        def to_html
            @html
        end

        def to_nokogiri
            @noko
        end

        private

        def _translate_labels(attrs)
            attrs2 = {}

            # labels:
            #  keys: good labels
            #  values: parsed labels
            c_pars_keys = CONFIG[:parsing].keys
            c_pars_values = CONFIG[:parsing].values
            c_pars_values.push(nil)

            attrs.map do |k,v|
                attrs2[c_pars_values[c_pars_keys.index(k) || -1]] = v
            end
            attrs2
        end

        def _parse_book_from_trs(trs)
            nodes_attrs = {}

            trs.map do |n|
                lab, val = n.children # only 2 nodes

                lab = lab.children[0].to_s.strip
                val = val.children[0].to_s.strip

                nodes_attrs[lab] ||=[]
                nodes_attrs[lab].push(val)
            end

            Book.new(_translate_labels(nodes_attrs))
        end

        def _parse_one_book(noko_el)
            return nil if noko_el.nil?

            trs = noko_el.css('tr')
            # keep only usefull information
            trs.shift
            trs.shift
            trs.pop
            _parse_book_from_trs(trs)
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
