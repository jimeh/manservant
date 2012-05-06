module Manservant
  class ManPage

    class NotFound < StandardError; end

    attr_accessor :name
    attr_accessor :section
    attr_accessor :options

    def initialize(name, section = nil, options = {})
      @name = name
      @section = section
      @man2html_path = options[:man2html_path] || defaults[:man2html_path]
      @man2html_args = defaults[:man2html_args].merge(options[:man2html_args])
    end

    def sections
      @sections ||= {}
    end

    def to_text
      return @text if @text
      text = `#{man_cmd}`
      raise NotFound, "No manual entry for #{name}" if $?.to_i != 0
      @text = text.strip
    end

    def to_html
      return @html if @html
      to_text # raise exception if man page doesn't exist
      @html = post_process_html(`#{man_cmd} | #{man2html_cmd}`.strip)
    end

    private

    def post_process_html(html)
      # Strip empty lines from top of man page.
      html.gsub!(/^<PRE>\s*<\!\-\-.+\-\->\s*/, "<PRE>\n")

      # Fix capitalization of href property of links to self in man page
      # header.
      html.gsub!(/^<PRE>\s*<B><A.+?\/A><\/B>.+?<B><A.+?\/A><\/B>/) do |match|
        match.gsub(/HREF=\"(.*?)#{name.upcase}(.*?)\"/,
          "HREF=\"\\1#{name}\\2\"")
      end

      # Locate and attach id property to all section headers.
      html.gsub!(/<\/PRE>\s*<H2>\s*(.+?)\s*<\/H2>\s*<PRE>/) do |match|
        title = $1
        id = title.gsub(/[^a-z0-9\-_\.\s]/i, '').
          gsub(/[^a-z0-9]/i, '-').downcase
        sections[id] = title
        "<H2 id=\"#{id}\">#{title}</H2>"
      end
      html
    end

    def man_cmd
      section_arg = "-S \"#{section}\"" if section
      "man -P cat \"#{name}\" #{section_arg}"
    end

    def man2html_cmd
      args = @man2html_args.inject([]) do |result, (opt, val)|
        result << "-#{opt}"
        result << val.to_s if val && val != true
        result
      end
      "\"#{@man2html_path}\" #{args.join(' ')}"
    end

    def defaults
      {
        :man2html_path => 'man2html',
        :man2html_args => {
          :bare => true,
          :topm => 0
        }
      }
    end

  end # ManPage
end # Manservant
