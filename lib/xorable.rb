module Xorable
  def ^(stringish)
    xor_to_string bytes[0...stringish.length].zip(stringish.bytes)
  end

  private

  def xor_to_string(zipped_bytes)
    bytes_to_string(xor zipped_bytes)
  end

  def xor(zipped_bytes)
    zipped_bytes.map{ |x, y| x ^ y }
  end

  def bytes_to_string(bytes)
    bytes.pack('C*')
  end
end
