class Array
  def sum(start = 0)
    inject(start, &:+)
  end

  def second
    self[1]
  end

  def third
    self[2]
  end

  def fourth
    self[3]
  end

  def fifth
    self[4]
  end
end
