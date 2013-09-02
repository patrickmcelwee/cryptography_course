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
end
