#encoding: US-ASCII
require 'openssl'
require 'securerandom'
require_relative 'lib/xorable'

class String
  include Xorable
end

class AesCbc
  def initialize(initial_string, input_encoding: :ascii,
                 output_encoding: :ascii,
                 key:  ->{raise "needs a key"}.call)
    @initial_string = normalize_input initial_string, input_encoding
    @output_encoding = output_encoding
    @key = normalize_input key, :hex
  end

  def encrypt
    normalize_output encrypted_string, output_encoding
  end

  def decrypt
    normalize_output decrypted_string, output_encoding
  end

  private
  attr_reader :initial_string, :output_encoding, :key

  def decrypted_string
    iv = initial_string[0..15]
    block1 = initial_string[16..31]
    block2 = initial_string[32..47]
    decryption = ''

    message_block1 = decrypt_block(block1) ^ iv
    decryption << message_block1

    message_block2 = decrypt_block(block2) ^ block1
    decryption << message_block2
    unpad decryption

    decryption
  end

  def encrypted_string
    blocks = initial_string.chars.each_slice(16).map(&:join)
    pad blocks
    iv = SecureRandom.random_bytes(16)
    encryption = ''
    encryption << iv

    cipher_block = encrypt_block(iv ^ blocks[0])
    encryption << cipher_block

    cipher_block2 = encrypt_block(cipher_block ^ blocks[1])
    encryption << cipher_block2
    
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

  def encrypt_block(block)
    encrypter = OpenSSL::Cipher::AES.new(128, 'ECB')
    encrypter.encrypt
    encrypter.key = key
    result = encrypter.update(block)
    result
  end

  def pad(blocks)
    padded = false
    blocks.each do |block|
      if block.size < 16
        pad = 16 - block.size
        pad.times { block << pad.to_s }
        padded = true
      end
      blocks << ['0'] * 16 unless padded
    end
  end

  def unpad(decrypted_message)
    if decrypted_message[-1] == '0'
      decrypted_message.slice!(-16..-1)
    else
      padding = decrypted_message[-1].to_i
      decrypted_message.slice!(-padding..-1)
    end
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
end
