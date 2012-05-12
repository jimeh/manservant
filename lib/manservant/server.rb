require 'sinatra'

require 'manservant/man_page'

module Manservant
  class Server < Sinatra::Base

    set :public_folder, File.expand_path('../server/public', __FILE__)
    set :views, File.expand_path('../server/views', __FILE__)

    helpers do
      def parse_page_name(dirty_name)
        name = sanitize_name(dirty_name)
        redirect to("/#{name}") if name != dirty_name
        if name =~ /^(.+)\.(\d+?)$/
          [$1, $2]
        else
          [name, nil]
        end
      end

      def sanitize_name(name)
        name.gsub(/[^a-z0-9\-_\.]/i, '')
      end

      def parse_config_file
        config = {}
        File.open("#{ENV['HOME']}/.manservantrc").read.split("\n").map!{|x| x.split('=').map!{|y| y.strip}}.each{|e| config[e[0].to_sym] = e[1]}
        config
      end

      def find_page(name, section = nil)
        ManPage.new(name, section,
          :man2html_path => man2html_path,
          :man2html_args => { :cgiurl => '\'/${title}.${section}\'' })
      end

      def man2html_path
        File.expand_path('../../../libexec/man2html', __FILE__)
      end
    end # helpers

    #
    # Routes
    #

    get '/' do
      redirect to('/man')
    end

    get '/:page' do
      @config = parse_config_file
      @style = @config[:style] || "default"
      @name, @section = parse_page_name(params[:page])
      @page = find_page(@name, @section)
      begin
        @page.to_html # render and populate sections
      rescue Manservant::ManPage::NotFound => e
        raise Sinatra::NotFound
      end
      erb :page, :layout => :layout
    end

    #
    # Handlers
    #

    not_found do
      erb :not_found
    end

  end
end
