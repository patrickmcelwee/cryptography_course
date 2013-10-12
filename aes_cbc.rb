require 'openssl'
require 'securerandom'
require_relative 'lib/xorable'

class String
  include Xorable
end

class AesCipher
  def initialize(initial_string, input_encoding: :ascii,
                 output_encoding: :ascii,
                 key:  ->{raise "needs a key"}.call)
    @initial_string = (normalize_input initial_string, input_encoding).dup
    @output_encoding = output_encoding
    @key = normalize_input key, :hex
  end

  def normalize_input(input, input_encoding)
    case input_encoding
    when :ascii
      input
    when :hex
      input.scan(/../).map { |x| x.hex }.pack('C*')
    else
      raise "Not a known encoding: #{input_encoding}"
    end
  end

  def encrypt
    normalize_output encrypted_string, output_encoding
  end

  def decrypt
    normalize_output decrypted_string, output_encoding
  end

  private
  attr_reader :initial_string, :output_encoding, :key
  
  def normalize_output(output, output_encoding)
    case output_encoding
    when :ascii
      output
    when :hex
      output.unpack('H*').first
    else
      raise "Not a known encoding: #{input_encoding}"
    end
  end

  def pad(blocks)
    padded = false
    blocks.each do |block|
      if block.size < 16
        pad = 16 - block.size
        if pad < 10
          pad.times { block << pad.to_s }
        else
          (pad-1).times { block << (pad-10).to_s }
          block << "|"
        end
        padded = true
      end
    end
    blocks << "0" * 16 unless padded
  end

  def encrypt_block(block)
    encrypter = OpenSSL::Cipher::AES.new(128, 'ECB')
    encrypter.encrypt
    encrypter.key = key
    result = encrypter.update(block)
    result
  end

  def unpad(decrypted_message)
    padding = case decrypted_message[-1]
              when '0'
                16
              when '|'
                decrypted_message[-2].to_i + 10
              else
                decrypted_message[-1].to_i
              end
    decrypted_message.slice!(-padding..-1)
  end
end

class AesCtr < AesCipher
  private

  # Note: These two methods basically the same, except how they generate
  # nonce (one generates and other just receives)
  def encrypted_string
    blocks = initial_string.chars.each_slice(16).map(&:join)

    nonce = SecureRandom.random_bytes(8)
    counter = [0] * 8
    counter_bytes = counter.pack('C*')
    encryption = nonce + counter_bytes

    blocks.each do |block|
      cipher_block = block ^ encrypt_block(nonce + counter_bytes)
      encryption << cipher_block
      counter[-1] += 1
      counter_bytes = counter.pack('C*')
    end

    encryption
  end

  def decrypted_string
    iv = initial_string.slice!(0..15)
    decryption = ''

    blocks = initial_string.chars.each_slice(16).map(&:join)
    blocks.each do |block|
      message_block = block ^ encrypt_block(iv)
      decryption << message_block
      iv_counter = iv.bytes
      iv_counter[-1] += 1
      iv = iv_counter.pack('C*')
    end

    decryption
  end
end

class AesCbc < AesCipher
  private

  def decrypted_string
    iv = initial_string.slice!(0..15)
    decryption = ''

    blocks = initial_string.chars.each_slice(16).map(&:join)

    blocks.inject(iv) do |xorable, block|
      message_block = decrypt_block(block) ^ xorable
      decryption << message_block
      block
    end
    #unpad decryption
    decryption
  end

  def encrypted_string
    blocks = initial_string.chars.each_slice(16).map(&:join)
    pad blocks
    iv = SecureRandom.random_bytes(16)
    encryption = iv

    blocks.inject(iv) do |xorable, block|
      cipher_block = encrypt_block(xorable ^ block)
      encryption << cipher_block
      cipher_block
    end
    encryption
  end

  def decrypt_block(block)
    decrypter = OpenSSL::Cipher::AES.new(128, 'ECB')
    decrypter.decrypt
    decrypter.key = key
    decrypter.padding = 0
    result = decrypter.update(block)
    result
  end
end
