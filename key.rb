require_relative 'lib/xorable'
require_relative 'lib/string_like'

class Key
  include Xorable
  include StringLike

  attr_reader :string

  def initialize(string)
    @string = string
  end

  def self.unknown_for_ciphers(ciphers)
    new ('?' * max_length_of(ciphers))
  end

  private
  
  def self.max_length_of(ciphers)
    ciphers.inject(ciphers.first.length) do |max_length, cipher|
      max_length > cipher.length ? max_length : cipher.length
    end
  end
end
