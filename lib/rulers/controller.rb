require 'erubis'
require 'rack/request'
require_relative 'file_model'

module Rulers
  class Controller
    include Rulers::Model

    attr_reader :env, :request
    def initialize(env)
      @env = env
      @request ||= Rack::Request.new(@env)
    end

    def response(text, status = 200, headers = {} )
      raise "Already responded!" if @response
      a = [text].flatten
      @response = Rack::Response.new(a, status, headers)
    end

    def get_response
      @response
    end

    def render_response(*args)
      response(render(*args))
    end

    def params
      request.params
    end

    def render(view_name, locals = {})
      filename = File.join("app", "views", controller_name, "#{view_name}.html.erb")
      template = File.read filename
      eruby = Erubis::Eruby.new(template)

      # passing env to the view makes variables available in the view
      # like we're used to in Rails and Sinatra
      eruby.result locals.merge(env: env, variables: fetch_instance_variables)
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, "") # remove the Controller from class name
      Rulers.to_underscore(klass)
    end

    def fetch_instance_variables
      variables = self.instance_variables
      variables.delete(:@env)
      variables
    end
  end
end
