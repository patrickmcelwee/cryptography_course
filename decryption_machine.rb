require 'term/ansicolor'
require_relative 'cipher'
require_relative 'message'
require_relative 'key'
require_relative 'ciphers'

class DecryptionMachine
  attr_accessor :ciphers, :messages, :key

  def initialize(hex_ciphers)
    @ciphers = hex_ciphers.map { |cipher| Cipher.from_hex_string(cipher)}
    @messages = ciphers.map { |cipher| Message.from_cipher(cipher) }
    @key = Key.unknown_for_ciphers(ciphers)
  end

  def run
    ciphers.each_with_index do |cipher, current_cipher_index|
      break if cipher.equal?(ciphers.last)
      next_cipher = ciphers[current_cipher_index + 1]

      message_xor = (cipher ^ next_cipher)

      possible_space_positions = []
      index = 0
      message_xor.each do |xor_byte|
        #break if index >= max_cipher_length # too much?
        possible_space_positions << index if (65 <= xor_byte && xor_byte <= 122)
        index += 1
      end

      possible_space_positions.each do |space_index|
        puts "There is likely a space at #{space_index}"

        puts "If it is in the first message, then:"
        clones1 = messages.map do |message|
          String.new message
        end
        clone_key1 = String.new key
        clone_key1[space_index] = decrypter.xor_to_string(' ', cipher[space_index])

        clones1.each_with_index do |clone, clone_index|
          clone[space_index] = decrypter.xor_to_string(clone_key1[space_index], ciphers[clone_index][space_index])
          print "message #{clone_index}: #{clone[0..space_index-1]}" + Term::ANSIColor.red + clone[space_index] + Term::ANSIColor.clear + clone[space_index+1..-1] + "\n"
        end

        puts ''
        puts "If it is in message_b, then:"
        clones2 = messages.map do |message|
          String.new message
        end
        clone_key2 = String.new key
        clone_key2[space_index] = decrypter.xor_to_string(' ', next_cipher[space_index])

        clones2.each_with_index do |clone, clone_index|
          clone[space_index] = decrypter.xor_to_string(clone_key2[space_index], ciphers[clone_index][space_index])
          print "message #{clone_index}: #{clone[0..space_index-1]}" + Term::ANSIColor.red + clone[space_index] + Term::ANSIColor.clear + clone[space_index+1..-1] + "\n"
        end

        puts ''
        puts "1 / 2 / (s)kip"
        case gets.chomp
        when '1'
          message_index = 0
          self.messages.map! do |message|
            message = clones1[message_index]
            message_index += 1
            message
          end
        when '2'
          message_index = 0
          self.messages.map! do |message|
            message = clones2[message_index]
            message_index += 1
            message
          end
        end
      end
    end
  end
end

class PadEncrypter
  def encrypt(key, message)
    cipher = Cipher.new ((key ^ message).unpack('H*').first)
  end
end
