class Object
  # Allows for rails magic of autoloading
  def self.const_missing(c)
    return nil if @calling_const_missing # prevents infinite recursion

    @calling_const_missing = true
    require Rulers.to_underscore(c.to_s)
    klass = Object.const_get(c)
    @calling_const_missing = false

    klass
  end
end
