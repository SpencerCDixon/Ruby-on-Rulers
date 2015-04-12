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
      binding.pry
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&block)
    end

    def get_rack_app(env)
      binding.pry
      raise 'No routes!' unless @route_obj
      binding.pry
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
    binding.pry
    @rules.each do |r|
      m = r[:regexp].match(url)

      if m
        options = r[:options]
        params = options[:default].dup
        r[:vars].each_with_index do |v, i|
          params[v] = m.captures[i]
        end
        dest = nil
        if r[:dest]
          return get_dest(r[:dest], params)
        else
          controller = params["controller"]
          action = params["action"]
          return get_dest("#{controller}" +
            "##{action}", params)
        end
      end
    end

    nil
  end

  def get_dest(dest, routing_params = {})
    binding.pry
    return dest if dest.respond_to?(:call)
    if dest =~ /^([^#]+)#([^#]+)$/
      name = $1.capitalize
      cont = Object.const_get("#{name}Controller")
      return cont.action($2, routing_params)
    end
    raise "No destination: #{dest.inspect}!"
  end
end
