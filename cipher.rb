require_relative 'lib/xorable'

class Cipher
  include Xorable

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

  def bytes
    string.bytes
  end

  def length
    string.length
  end

  private
  attr_reader :string
end
