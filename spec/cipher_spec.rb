require_relative '../cipher'
require 'xorable_class_spec'
require 'string_like_class_spec'

describe Cipher do
  subject {Cipher.new('abc')}

  it_behaves_like "an_xorable_class"
  it_behaves_like "a string-like class" 
  context 'self.from_hex_string' do
    it "returns an object encoding an ascii equivalent" do
      expect(described_class.from_hex_string('315c').to_s).to eq('1\\')
      expect(described_class.from_hex_string('5c314e').to_s).to eq('\\1N')
    end
  end

end
