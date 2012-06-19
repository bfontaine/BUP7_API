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

        def to_uri_params()

            # expand shortcuts
            def expand_libs(l)
                # all
                l.concat((1..11).to_a) if l.include? 0
                # sciences
                l.concat([3,5,7,9]) if l.include? 1
                # health
                l.concat([4,6,8,10,11]) if l.include? 2
            end

            # strange parameters
            def set_floc(l)
                f = []
                f.concat( (60000..60015).to_a ) if l.include? 3
                f.concat((100000..100006).to_a ) if l.include? 4
                f.concat( (80000..80003).to_a ) if l.include? 5
                f.concat( (20000..20003).to_a ) if l.include? 6
                f.concat( (70000..70006).to_a ) if l.include? 7
                f.push(30000) if l.include? 8
                f.concat( (90000..90002).to_a ) if l.include? 9
                f.concat( (40000..40001).to_a ) if l.include? 10
                f.concat( (50000..50008).to_a+[100000] ) if l.include? 11

                f
            end

            uri_params = {}

            # constants
            CONFIG[:consts].each do |lb,v|
                uri_params[lb] = v
            end

            # keywords
            CONFIG[:labels][:keywords].each_with_index do |lb,i|
                lb.each { |l| uri_params[l] = @keywords[i].to_s }
            end

            CONFIG[:labels][:keywords_types].each_with_index do |lb,i|
                lb.each { |l| uri_params[l] = @keywords_types[i].to_s }
            end

            CONFIG[:labels][:operations].each_with_index do |lb,i|
                lb.each { |l| uri_params[l] = @keywords_ops[i].to_s }
            end

            # years
            uri_params[CONFIG[:labels][:after]] = @params[:after]
            uri_params[CONFIG[:labels][:before]] = @params[:before]

            libraries = [CONFIG[:values][:libraries][:all]]

            if @params[:libraries]
                libraries = []
                @params[:libraries].map do |lib|
                    libraries.push(CONFIG[:values][:libraries][lib])
                end
                libraries = libraries.uniq.delete_if { |e| e.nil? }
            end

            libraries = expand_libs(libraries)
            uri_params[CONFIG[:labels][:libraries]] = libraries
            uri_params[CONFIG[:labels][:floc]] = set_floc(libraries)

            if @params[:langs]
                uri_params[CONFIG[:labels][:langs_inc]] =
                    1 if @flags.include? :include_langs
                uri_params[CONFIG[:labels][:langs_inc]] = 
                    0 if @flags.include? :exclude_langs
            end

            docs = [CONFIG[:values][:documents][:all_docs]]
            if @params[:documents]
                docs = []
                @params[:documents].map do |doc|
                    docs.push(CONFIG[:values][:documents][doc])
                end
                docs = docs.uniq.delete_if { |e| e.nil? }
            end

            uri_params
        end

        def to_s
            CONFIG[:url] + URI.encode_www_form(self.to_uri_params)
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

            CONFIG[:values][:keywords].each do |label,value|
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
