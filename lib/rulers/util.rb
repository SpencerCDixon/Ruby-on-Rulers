module Rulers
  def self.to_underscore(string)
    string.gsub(/::/, '/'). # removes namespaced constants ::
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2'). # \1 and \2 mean first and second found
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end
