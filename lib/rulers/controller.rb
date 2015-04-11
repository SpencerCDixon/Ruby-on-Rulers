require 'erubis'

module Rulers
  class Controller
    include Rulers::Model

    def initialize(env)
      @env = env
    end

    def env
      @env
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
