class Cipher
  def self.from_hex_string(hex_string)
    ascii_string = [hex_string].pack('H*')
    new(ascii_string)
  end

  def initialize(string)
    @string = string
  end

  def to_s
    string
  end

  def ^(stringish)
    xor_to_string bytes[0...stringish.length].zip(stringish.bytes)
  end

  def bytes
    string.bytes
  end

  def length
    string.length
  end

  private
  attr_reader :string

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
