module Rulers
  class Application
    # def get_controller_and_action(env)
      # # _ is used to store stuff we don't use.
      # _, cont, action, after =
        # env["PATH_INFO"].split('/', 4)

      # cont = cont.capitalize # takes controller name and capitalizes it
      # cont += "Controller"

      # [Object.const_get(cont), action]
      # # const_get is a method from Kernel most likely that will look up any
      # # constants (like our controllers name)
    # end

    def route(&block)
      # this gets called as soon as user hits enter on url bar
      # creates a Route Object if one doesn't already exist
      @route_obj ||= RouteObject.new
      # block is coming from the config.ru, its all the possible routes being
      # passed into the RouteObject
      @route_obj.instance_eval(&block)
    end

    def get_rack_app(env)
      # will raise error if there are no routes defined in the config.ru
      # needs routes there in order to match URL's properly
      raise 'No routes!' unless @route_obj
      @route_obj.check_url(env["PATH_INFO"])
    end
  end
end

# Route Object is really just responsible for matching whatever the path was in
# the url to the proper controller/action
class RouteObject
  def initialize
    @rules = []
  end

  def match(url, *args)
    options = {}
    options = args.pop if args[-1].is_a?(Hash)
    options[:default] ||= {}

    dest = nil
    dest = args.pop if args.size > 0
    raise "Too many args!" if args.size > 0

    parts = url.split("/")
    parts.select! { |p| !p.empty? }

    vars = []
    regexp_parts = parts.map do |part|
      if part[0] == ":"
        vars << part[1..-1]
        "([a-zA-Z0-9]+)"
      elsif part[0] == "*"
        vars << part[1..-1]
        "(.*)"
      else
        part
      end
    end

    regexp = regexp_parts.join("/")
    @rules.push({
      :regexp => Regexp.new("^/#{regexp}$"),
      :vars => vars,
      :dest => dest,
      :options => options,
    })
  end

  def check_url(url)
    # has all route rules saved in @rules
    # iterates through to see if the given url from the request
    # matches any of the regex rules
    @rules.each do |r|
      m = r[:regexp].match(url)
      # uses each rule regex to try and match url,
      # if there is a match then set more options

      if m
        # if the url matches one of the rules in config.ru
        # 1 gets saved as the controller
        options = r[:options]
        # options are what gets passed after comma in config.ru
        # copy the options into a params hash
        params = options[:default].dup


        r[:vars].each_with_index do |v, i|
          # for each regex capture assign a key value pair into the params hash
          # that will get passed back
          params[v] = m.captures[i]
        end

        dest = nil
        if r[:dest]
          return get_dest(r[:dest], params)
          # if dest already exists then go fetch it and pass new params hash in
        else
          # otherwise set up the proper destination
          # by getting the controller/action from the params hash
          controller = params["controller"]
          action = params["action"]

          # call get_dest with the controller and action properly separated by a
          # hashtag in order for get_dest to parse properly, also pass in
          # params for the request
          return get_dest("#{controller}##{action}", params)
        end
      end
    end

    nil
  end

  def get_dest(dest, routing_params = {})
    # if dest is already a rack object then return it
    return dest if dest.respond_to?(:call)

    # use regex to match the controller and action for the request properly
    if dest =~ /^([^#]+)#([^#]+)$/
      name = $1.capitalize
      # $1 is the controller name
      cont = Object.const_get("#{name}Controller")
      # $2 is the action name
      return cont.action($2, routing_params)
    end
    # if it can't properly match a controller and action then raise an error
    raise "No destination: #{dest.inspect}!"
  end
end
