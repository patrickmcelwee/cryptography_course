#encoding: US-ASCII
require_relative '../aes_cbc'

describe AesCbc do
  it "encrypts and decrypts a message with hex encoding" do
    plain_text_message = "This is a top-secret message!"
    message = plain_text_message.unpack('H*').first
    key = '140b41b22a29beb4061bda66b6747e14'
    encrypter = AesCbc.new(message, input_encoding: :hex, key: key)
    cipher = encrypter.encrypt
    
    expect(cipher.size).to eq 48

    plain_text_decrypter = AesCbc.new(cipher, key: key)
    expect(plain_text_decrypter.decrypt).to eq(plain_text_message)

    decrypter = AesCbc.new(cipher, output_encoding: :hex, key: key)
    expect(decrypter.decrypt).to eq(message)
  end

  xit "works for a short message" do
    message = "This is me."
    key = SecureRandom.random_bytes(16).unpack('H*').first
    encrypter = AesCbc.new(message, key: key)
    cipher = encrypter.encrypt

    decrypter = AesCbc.new(cipher, key: key)
    expect(decrypter.decrypt).to eq(message)
  end
end
