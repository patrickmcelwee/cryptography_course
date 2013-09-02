require_relative '../message'

describe Message do
  context 'self.from_cipher' do
    it "returns question marks for length of cipher" do
      expect(described_class.from_cipher('abc').to_s).to eq('???')
      expect(described_class.from_cipher('9\\N*').to_s).to eq('????')
    end
  end
end
