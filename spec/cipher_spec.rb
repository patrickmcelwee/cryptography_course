require_relative '../cipher'
require 'xorable_class_spec'

describe Cipher do
  subject {Cipher.new('abc')}

  it_behaves_like "an_xorable_class"

  context 'self.from_hex_string' do
    it "returns an object encoding an ascii equivalent" do
      expect(described_class.from_hex_string('315c').to_s).to eq('1\\')
      expect(described_class.from_hex_string('5c314e').to_s).to eq('\\1N')
    end
  end

  context 'length' do
    it "returns appropriate length" do
      expect(Cipher.new('').length).to  eq(0)
      expect(Cipher.new('1').length).to eq(1)
      expect(Cipher.new('abcdefg').length).to eq(7)
    end
  end

  context 'bytes' do
    it "returns ascii bytes of its cipher string" do
      expect(subject.bytes).to eq([97, 98, 99])
    end
  end
end
