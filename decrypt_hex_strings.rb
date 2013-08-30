CIPHER1 = '315c4eeaa8b5f8aaf9174145bf43e1784b8fa00dc71d885a804e5ee9fa40b16349c146fb778cdf2d3aff021dfff5b403b510d0d0455468aeb98622b137dae857553ccd8883a7bc37520e06e515d22c954eba5025b8cc57ee59418ce7dc6bc41556bdb36bbca3e8774301fbcaa3b83b220809560987815f65286764703de0f3d524400a19b159610b11ef3e'

CIPHER2 = '234c02ecbbfbafa3ed18510abd11fa724fcda2018a1a8342cf064bbde548b12b07df44ba7191d9606ef4081ffde5ad46a5069d9f7f543bedb9c861bf29c7e205132eda9382b0bc2c5c4b45f919cf3a9f1cb74151f6d551f4480c82b2cb24cc5b028aa76eb7b4ab24171ab3cdadb8356f'

CIPHER3 = '32510ba9a7b2bba9b8005d43a304b5714cc0bb0c8a34884dd91304b8ad40b62b07df44ba6e9d8a2368e51d04e0e7b207b70b9b8261112bacb6c866a232dfe257527dc29398f5f3251a0d47e503c66e935de81230b59b7afb5f41afa8d661cb'

CIPHER4 = '32510ba9aab2a8a4fd06414fb517b5605cc0aa0dc91a8908c2064ba8ad5ea06a029056f47a8ad3306ef5021eafe1ac01a81197847a5c68a1b78769a37bc8f4575432c198ccb4ef63590256e305cd3a9544ee4160ead45aef520489e7da7d835402bca670bda8eb775200b8dabbba246b130f040d8ec6447e2c767f3d30ed81ea2e4c1404e1315a1010e7229be6636aaa'

CIPHERS = [CIPHER1, CIPHER2, CIPHER3, CIPHER4]

class DecryptionMachine
  attr_accessor :ciphers, :decrypter, :messages, :key, :max_cipher_length

  def initialize(hex_ciphers)
    @decrypter = ManyTimePadDecrypter.new
    @ciphers = hex_ciphers.map { |cipher| decrypter.ascii_string_for(cipher)}
    @messages = ciphers.map { |cipher| '?' * cipher.length }
    @max_cipher_length = find_min_length(ciphers)
    @key = "?" * max_cipher_length
  end

  def find_min_length(arrays)
    max_length = 10000000
    arrays.each do |array|
      max_length = array.length if array.length < max_length
    end
    max_length
  end

  def run
    ciphers.each_with_index do |cipher, current_cipher_index|
      break if cipher.equal?(ciphers.last)
      next_cipher = ciphers[current_cipher_index + 1]

      message_xor = decrypter.xor(cipher, next_cipher)

      possible_space_positions = []
      index = 0
      message_xor.each do |xor_byte|
        break if index >= max_cipher_length
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
          puts "message #{clone_index}: #{clone}"
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
          puts "message #{clone_index}: #{clone}"
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

class ManyTimePadDecrypter
  def get_xor(cipher1, cipher2)
    ascii_cipher1 = ascii_string_for cipher1
    ascii_cipher2 = ascii_string_for cipher2
    xor(ascii_cipher1, ascii_cipher2)
  end

  def xor_to_string(string1, string2)
    xor(string1, string2).pack('C*')
  end

  def xor(string1, string2)
    zipped = if string1.length > string2.length
               string1_bytes = string1[0..(string2.length - 1)].bytes
               string2_bytes = string2.bytes
               string1_bytes.zip(string2_bytes)
             else
               string2[0..(string1.length - 1)].bytes.zip(string1.bytes)
             end

    zipped.map { |x, y| x ^ y }.flatten
  end

  def ascii_string_for(hex_string)
    [hex_string].pack('H*')
  end

  def bytes_for(hex_string)
    ascii_string_for(hex_string).bytes
  end

  def encrypt(key, message)
    cipher = xor(key, message)
    cipher.unpack('H*').first
  end
end
