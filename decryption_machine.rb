require 'term/ansicolor'
require_relative 'cipher'
require_relative 'message'
require_relative 'key'
require_relative 'ciphers'

class String
  include Xorable
end

class DecryptionMachine
  attr_accessor :ciphers, :messages, :key

  def initialize(hex_ciphers)
    @ciphers = hex_ciphers.map { |cipher| Cipher.from_hex_string(cipher)}
    @messages = ciphers.map { |cipher| Message.from_cipher(cipher) }
    @key = Key.unknown_for_ciphers(ciphers)
  end

  def auto_decrypt
    ciphers.each_with_index do |cipher, cipher_index|
      break if cipher.equal?(ciphers.last)
      #TODO: compare to EACH other cipher
      next_cipher = ciphers[cipher_index + 1]
      message_xor = cipher ^ next_cipher
      message_xor.bytes.each_with_index do |byte, char_index|
        if probably_xored_with_space?(byte)
          if key = likely_key(char_index, cipher, next_cipher)
            messages.each_with_index do |m, i|
              m[char_index] = ciphers[i][char_index] ^ key if ciphers[i][char_index]
            end
          end
        end
      end
    end
    messages.each {|m| puts "message: #{m}"}
    messages.map(&:to_s)
  end

  def likely_key(index, cipher1, cipher2)
    key1 = key_for(cipher1, index)
    key2 = key_for(cipher2, index)
    better_key(key1, key2, index)
  end

  def better_key(key1, key2, index)
    chars1 = decrypted_message_chars_for(key1, index)
    chars2 = decrypted_message_chars_for(key2, index)
    score1 = score_chars(chars1)
    score2 = score_chars(chars2)
    return nil if score1 == score2
    return nil if score1 - score2 < 5 && score2 - score1 < 5
    score1 > score2 ? key1 : key2
  end

  def score_chars(chars)
    score = 0
    chars.each do |char|
      next unless char
      score += 2 if char.match /[a-z]/
      score += 2 if char.match /\s/
      score += 1 if char.match /[A-Z]/
      score += 1 if char.match /e/
      score += 1 if char.match /[etaoinshr]/
      score += 1 if char.match /[0-9]/
      score += 1 if char.match /[.:!?,'"]/
      score -= 1 if char.match /[jxqz]/
    end
    p score
    score
  end

  def decrypted_message_chars_for(key, index)
    ciphers.map{|cipher| next unless cipher[index]; cipher[index] ^ key}
  end

  def key_for(cipher, index)
    cipher[index] ^ " "
  end

  private
  def probably_xored_with_space?(byte)
    65 <= byte && byte <= 122
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
    cipher = (key ^ message).unpack('H*').first
  end
end
