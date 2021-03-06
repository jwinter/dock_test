module DockTest
  module DSL

    attr_reader :url
    # sets the test url
    # also creates a new webrick server process
    def url=(value)
      @url = value

      if localhost? && @server_thread.nil?
        require "rack"
        require 'webrick'

        ARGV.clear # clear ARGV as it is used by Rack to configure server

        server = WEBrick::HTTPServer.new(:Port => port).tap do |server|
          server.mount '/', Rack::Handler::WEBrick, Rack::Server.new.app
        end
        @server_thread = Thread.new { server.start }
        trap('INT') do
          server.shutdown
          exit
        end
      end
    end

    # oauth settings
    attr_accessor :oauth_consumer_key, :oauth_consumer_secret

    # if the current dock_test environment requires oauth
    def oauth?
      oauth_consumer_key && oauth_consumer_secret
    end

    def port
      URI.parse(@url).port
    end

    def localhost?
      @url && ['127.0.0.1', 'localhost'].include?(URI.parse(@url).host)
    end

    def skippy=(skippy)
      @skippy = skippy
    end

    def skippy?
      @skippy || false
    end

    def configure(&block)
      block.call(DockTest)
    end
  end
end
