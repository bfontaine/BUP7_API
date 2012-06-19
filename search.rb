#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

require 'uri'
require 'yaml'
require 'net/http'

URL = 'http://catalogue-scd.univ-paris-diderot.fr/cgi-bin/gw_48_1_14_1/chameleon?'

CONFIG = begin
             YAML.load(File.read('url_params.yaml'))
         rescue Errno::ENOENT
             {}
         end

class BUP7

    class SearchResult

    end

    class Search

        @@uri = URI(URL)

        @@config = CONFIG.clone

        def initialize()
            @params = {}
        end

        def params()
            yield @params
        end

        def encode()
            uri_params = CONFIG[:consts].clone

            mult_params = [:keywords, :keywords_types, :operations]

            @params.each do |k,v|
                next if mult_params.include? k

                label = CONFIG[:labels][k]
                v = [v] if !v.is_a?(Array)
                value = v.map { |e| CONFIG[:values][e].to_s }

                uri_params[label.to_s] = value.to_s
            end
            
            mult_params.each do |param|
                @params[param].each_with_index do |i,value|
                    CONFIG[:labels[i]].each do |label|
                        uri_params[label] = value
                    end
                end
            end

            URI.encode_www_form(uri_params)
        end



    end
end
