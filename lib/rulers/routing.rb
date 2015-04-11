module Rulers
  class Application
    def get_controller_and_action(env)
      # _ is used to store stuff we don't use.
      _, cont, action, after =
        env["PATH_INFO"].split('/', 4)

      cont = cont.capitalize # takes controller name and capitalizes it
      cont << "Controller"

      [Object.const_get(cont), action]
      # const_get is a method from Kernel most likely that will look up any
      # constants (like our controllers name)
    end
  end
end
