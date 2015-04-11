# Core gem libraries
require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"
require "rulers/file_model"

# Adding my own helper libraries to the gem
require "rulers/array"

module Rulers
  class Application
    def call(env)

      # handle browsers looking for favicon, return 404
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, { 'Content-Type' => 'text/html' }, []]
      end

      rack_app = get_rack_app(env)
      rack_app.call(env)
    end
  end
end
