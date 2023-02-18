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
      @man_cols = options[:man_cols] || defaults[:man_cols]
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
      STDERR.puts "Running '#{man_cmd} | #{man2html_cmd}'..."
      @html = post_process_html(`#{man_cmd} | #{man2html_cmd}`.strip)
    end

    private

    def post_process_html(html)
      # Strip empty lines from top of man page.
      html.gsub!(/^<PRE>\s*<\!\-\-.+\-\->\s*/, "<PRE>\n")

      # Fix capitalization of href property of links to self in man page
      # header. Note that 'man2html' doesn't create these links on Linux,
      # because it seems to ignore the overstrike (bold) font.
      html.gsub!(/^<PRE>\s*<B><A.+?\/A><\/B>.+?<B><A.+?\/A><\/B>/) do |match|
        match.gsub(/HREF=\"(.*?)#{name.upcase}(.*?)\"/,
          "HREF=\"\\1#{name}\\2\"")
      end

      # Locate and attach id property to all section headers.
      html.gsub!(/<\/PRE>\s*<H2>\s*(.+?)\s*<\/H2>\s*<PRE>/) do |match|
        title = $1

        if title =~ /#{name.upcase}/
          # on Linux, the header and footer also get turned into H2s, too; turn
          # these back into regular text so they don't overrun the right margin
          "#{title}" 
        else
          id = title.gsub(/[^a-z0-9\-_\.\s]/i, '').
            gsub(/[^a-z0-9]/i, '-').downcase
          sections[id] = title
          "<H2 id=\"#{id}\">#{title}</H2>"
        end
      end
      html
    end

    def man_cmd
      man_args = "\"#{name}\""
      man_args = "#{section} #{man_args}" if section
      "COLUMNS=#{@man_cols} man -P cat #{man_args}"
    end

    def man2html_cmd
      args = @man2html_args.inject([]) do |result, (opt, val)|
        # noop if val is false
        if val
          result << "-#{opt}"
          result << val.to_s if val && val != true
        end
        result
      end
      "\"#{@man2html_path}\" #{args.join(' ')}"
    end

    def defaults
      {
        :man2html_path => 'man2html',
        :man2html_args => {
          :bare => true,
          :topm => 0,
          # '-sun' option detects headings that have not been bolded with
          # overstrike (which seems to be the case with Linux's 'man' command)
          :sun => (RUBY_PLATFORM =~ /linux/) ? true : false,
        },
        # seems to be required on Linux; 78 works pretty well on both Mac and
        # Linux after bumping up the 'left' position of the navigation div
        :man_cols => 78
      }
    end

  end # ManPage
end # Manservant
