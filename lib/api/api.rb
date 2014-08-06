module Api
  class Base
    include HTTParty
    
    def initialize(options={})
      @server = options[:server]
      @site = options[:site]
    end
      
    def error(message)
      raise message
    end
    
    private 
    def interact(method, url, options={})
      self.class.send(method, url, options)
    rescue SocketError
      error "Connection error"
    end
    
    def method_missing(method, *args)
      respond_to?(method) ? interact(method, *args) : super
    end
    
    def respond_to?(method)
      return true if [:put, :post, :delete, :get].include? method.to_sym
      super
    end
  end
  
  Dir["./lib/api/*.rb"].each {|file| require file}
end