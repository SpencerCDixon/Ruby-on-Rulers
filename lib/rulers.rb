require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"
require "rulers/file_model"

# Adding my own libraries to the gem
require "rulers/array"

module Rulers
  class Application
    def call(env)
      # handle browsers looking for favicon, return 404
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, { 'Content-Type' => 'text/html' }, []]
      end

      # handle home page
      if env['PATH_INFO'] == '/'
        return [301, { 'Content-Type' => 'text/html' }, ['something']]
      end

      # double variable assignment #get_controller_and_action will return an
      # array of 2 things. Class for controller and action name
      klass, act = get_controller_and_action(env)
      controller = klass.new(env)

      begin
        text = controller.send(act) # get http response body from controller's action
      rescue
        text = handle_exceptions
      end

      [200, {'Content-Type' => 'text/html'}, [text]]
    end

    def handle_exceptions
      "Something went terribly wrong, Rulers was unable to make a request to that path"
    end
  end
end
