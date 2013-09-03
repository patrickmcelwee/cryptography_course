module StringLike
  def string
    raise NotImplementedError, "#string must exist on StringLike class."
  end

  def to_s
    string
  end

  def bytes
    string.bytes
  end

  def length
    string.length
  end

  def [](index)
    string[index]
  end

  def []=(index, value)
    string[index] = value
  end
end
