require_relative '../decryption_machine'

describe DecryptionMachine do
  it "works for a simple example with spaces" do
    key = Key.new "abc"
    ms1 = Message.new " hi"
    ms2 = Message.new "ok "
    ms3 = Message.new "u e"
    encrypter = PadEncrypter.new
    cipher1 = encrypter.encrypt(key, ms1)
    cipher2 = encrypter.encrypt(key, ms2)
    cipher3 = encrypter.encrypt(key, ms3)

    decrypter = DecryptionMachine.new([cipher1, cipher2, cipher3])
    expect(decrypter.auto_decrypt).to eq([ms1, ms2, ms3].map(&:to_s))
  end

  it "works for messages of unequal lengths"
end

