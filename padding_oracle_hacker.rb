require 'open-uri'

class PaddingOracleHacker
  def initialize(query_url, ciphertext)
    @ciphertext = ciphertext
  end

  def blocks
    @blocks ||= ciphertext.scan(/.{32}/)
  end

  def guess(pad: 1, byte_guess: 0)
    previous_block_hex_byte = blocks[-2][-2..-1]
    new_last_byte = (pad ^ byte_guess ^ previous_block_hex_byte.hex)
    new_last_hex_byte = [new_last_byte].pack('C*').unpack('H*').first
    blocks[-2][-2..-1] = new_last_hex_byte
    blocks.join
  end

  private
  attr_reader :ciphertext
end

class PaddingOracleTester
  def initialize(base_url)
    @base_url = base_url
  end

  def query_target(ciphertext)
    response = open base_url + ciphertext
    response.status.first
  rescue OpenURI::HTTPError => error
    status_code_for error.message
  end

  private
  attr_reader :base_url

  def status_code_for(error_message)
    error_message[0..2]
  end
end
