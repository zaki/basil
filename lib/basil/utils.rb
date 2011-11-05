module Basil
  # Utility functions that are useful across multiple plugins should
  # reside here. They are mixed into the Plugin class.
  module Utils
    def says(txt)
      Message.new(nil, Config.me, Config.me, txt)
    end

    def replies(txt)
      Message.new(@msg.from_name, Config.me, Config.me, txt)
    end

    def forwards_to(new_to)
      Message.new(new_to, Config.me, Config.me, @msg.text)
    end

    def require_authorization(type = nil) # to be implemented
      authorized_users = Config.authorized_users rescue []

      if authorized_users.include?(@msg.from)
        return yield
      else
        says "Sorry #{@msg.from_name}, I'm afraid I can't do that for you"
      end
    end

    def escape(str)
      require 'cgi'
      CGI::escape(str.strip)
    end

    # Make a simple or not-so simple request for json. Supports basic
    # auth and SSL. Prints to stderr and returns nil in case of errors.
    #
    #   get_json('http://example.com/some/path')
    #   get_json('example.com', '/some/path', 443, 'user', 'pass', true)
    #
    def get_json(host, path = nil, port = nil, username = nil, password = nil, secure = false)
      require 'json'

      if secure
        require 'net/https'
      else
        require 'net/http'
      end

      resp = if path || port || username || password
               net = Net::HTTP.new(host, port || 80)
               net.use_ssl = secure
               net.start do |http|
                 req = Net::HTTP::Get.new(path)
                 req.basic_auth username, password
                 http.request(req)
               end
             else
               Net::HTTP.get_response(URI.parse(host))
             end

      JSON.parse(resp.body)
    rescue Exception => e
      $stderr.puts e.message

      nil
    end
  end
end