#! /usr/bin/ruby1.9.1
# -*- coding: UTF-8 -*-

class BUP7
    class SearchQuery

        class QueryException < Exception
        end

        class TooManyKeywords < QueryException
        end

        def initialize(p)
            @flags = []
            @params = {}
            @keywords = []
            @keywords_types = []
            @keywords_ops = []
            _set_keywords(p)
        end

        # -- Keywords

        def and(p=nil)
            _set_keywords(p, 'AND') if (!p.nil?)
        end

        def or(p)
            _set_keywords(p, 'OR')
        end

        def except(p)
            _set_keywords(p, 'NOT')
        end

        # -- Libraries

        def in(libs)
            libs = [libs] if (!libs.is_a? Array)
            libs.uniq!

            @params[:libraries] ||= []
            @params[:libraries].concat(libs)
            self
        end

        # -- medias

        def for(docs)
            docs = [docs] if (!docs.is_a? Array)
            docs.uniq!

            @params[:documents] ||= []
            @params[:documents].concat(docs)
            self
        end

        # -- Years
        
        def before(year)
            @params[:before] = year
            self
        end
        
        def after(year)
            @params[:after] = year
            self
        end

        def between(y1, y2)
            after(y1)
            before(y2)
        end

        # -- Langs

        def include(langs)
           return self if (langs.nil?)
           raise QueryException if (@flags.include? :exclude_langs)
           @flags.push(:include_langs) if (!@flags.include? :include_langs)
           _add_langs(langs)
        end

        def exclude(langs)
           return self if (langs.nil?)
           raise QueryException if (@flags.include? :include_langs)
           @flags.push(:exclude_langs) if (!@flags.include? :exclude_langs)
           _add_langs(langs)
        end


        private

        def _add_langs(langs)
           langs = [langs] if (!langs.is_a?(Array))

           langs.each do |lang|
                next if !CONFIG[:values][:lang].include? lang

                @params[:langs] ||= []
                @params.push(CONFIG[:values][:lang][lang])
           end
           self
        end

        def _set_keywords(p, m='AND')
            raise SearchQuery::TooManyKeywords.new if @keywords.length == CONFIG[:limits][:keywords]

            p = {:all_words => p} if (p.is_a?(String))

            CONFIG[:values][:params].each do |label,value|
                next if p[label].nil?
                raise SearchQuery::TooManyKeywords.new if @keywords.length == CONFIG[:limits][:keywords]

                @keywords.push(p[label])
                @keywords_types.push(value)
                @keywords_ops.push('AND') if @keywords_ops.length > 0
            end

            self
        end
    end
end
