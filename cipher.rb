require_relative 'lib/xorable'
require_relative 'lib/string_like'

class Cipher
  include Xorable
  include StringLike

  def self.from_hex_string(hex_string)
    ascii_string = [hex_string].pack('H*')
    new(ascii_string)
  end

  def initialize(string)
    @string = string
  end

  private
  attr_reader :string
end
