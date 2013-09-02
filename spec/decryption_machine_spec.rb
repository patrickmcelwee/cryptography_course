require_relative '../decryption_machine'

describe DecryptionMachine do
  it "works for a simple example with spaces" do
    key = Key.new "abc"
    ms1 = Message.new " hi"
    ms2 = Message.new "hi "
    ms3 = Message.new "h i"
    encrypter = PadEncrypter.new
    cipher1 = encrypter.encrypt(key, ms1)
    cipher2 = encrypter.encrypt(key, ms2)
    cipher3 = encrypter.encrypt(key, ms3)

    decrypter = DecryptionMachine.new([cipher1, cipher2, cipher3])
    expect(decrypter.auto_decrypt).to eq([ms1, ms2, m3])
  end
end

