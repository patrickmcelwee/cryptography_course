require_relative '../padding_oracle_hacker'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = "spec/support"
  c.hook_into :webmock
end

describe PaddingOracleHacker do
  let(:aes_block) {'00112233445566778899aabbccddeeff'}
  subject {described_class.new('http://a.url', aes_block)}

  let(:longer_ciphertext) { aes_block + aes_block }
  let(:longer_subject) {described_class.new('a_url', aes_block + aes_block)}

  let(:valid_cipher) {'f20bdba6ff29eed7b046d1df9fb7000058b1ffb4210a580f748b4ac714c001bd4a61044426fb515dad3f21f18aa577c0bdf302936266926ff37dbf7035d5eeb4'}
  let(:real_example) {
    described_class.new('http://crypto-class.appspot.com/po?er=',
                        valid_cipher)}

  context '#discover_pad' do
    it "finds the pad from the class exercise" do
      VCR.use_cassette('discover_pad_class_exercise') do
        real_example.discover_pad
      end
      expect(real_example.known).to eq([9, 9, 9, 9, 9, 9, 9, 9, 9])
    end
  end

  it "can break ciphertext into blocks" do
    expect(subject.blocks).to eq([aes_block])
    expect(longer_subject.blocks).to eq([aes_block, aes_block])
  end

  context '#generate_guess' do
    it "can guess the decryption for the last byte" do
      expect(longer_subject.generate_guess(pad: 1, byte_guess: 0)).
        to eq('00112233445566778899aabbccddeefe' + aes_block)
    end

    it "can guess the decryption for the second byte" do
      longer_subject.stub(known: [0])
      expect(longer_subject.generate_guess(pad: 2, byte_guess: 1)).
        to eq('00112233445566778899aabbccddedfd' + aes_block)
    end
  end

  context '#decrypt_block' do
    it "decrypts the indicated block, starting with 1" do
      

    end
  end
end

describe PaddingOracleTester do
  subject {described_class.new('http://crypto-class.appspot.com/po?er=')}

  let(:valid_cipher) {'f20bdba6ff29eed7b046d1df9fb7000058b1ffb4210a580f748b4ac714c001bd4a61044426fb515dad3f21f18aa577c0bdf302936266926ff37dbf7035d5eeb4'}
  let(:invalid_cipher) {'f20bdba6ff29eed7b046d1df9fb7000058b1ffb4210a580f748b4ac714c001bd4a61044426fb515dad3f21f18aa577c0bdf302936266926ff37dbf7035d5eeb5'}

  it "sends supplied cipher to target site and returns error code" do
    VCR.use_cassette('valid_cipher_check') do
      expect(subject.query_target(valid_cipher)).to   eq('200')
    end

    VCR.use_cassette('invalid_cipher_check') do
      expect(subject.query_target(invalid_cipher)).to eq('403')
    end
  end
end
