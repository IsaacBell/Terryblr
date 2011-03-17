Terryblr.configure do |conf|
  conf.override 'PostsController', 'Terryblr::Post' => "Post"
end

module Rails
  class << self
    def database
      @_database ||= ActiveSupport::StringInquirer.new(Rails.configuration.database_configuration[Rails.env]["adapter"])
    end

    def app_name
      @_app_name ||= ActiveSupport::StringInquirer.new(APP_NAME || 'gamestore')
    end

    def host_ip
      @_host_ip ||= host_ip = Rails.env.development? ? "127.0.0.1" : Socket.getaddrinfo(Socket.gethostname, "www", Socket::AF_INET).first[3]
    end
  end
end
