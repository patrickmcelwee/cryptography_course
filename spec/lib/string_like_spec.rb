require_relative '../../lib/string_like'

class AStringLikeClass
  include StringLike
  attr_reader :string

  def initialize(string)
    @string = string
  end
end

describe StringLike do
  context 'length' do
    it "returns appropriate length" do
      expect(AStringLikeClass.new('').length).to  eq(0)
      expect(AStringLikeClass.new('1').length).to eq(1)
      expect(AStringLikeClass.new('abcdefg').length).to eq(7)
    end
  end

  context 'bytes' do
    it "returns ascii bytes of its cipher string" do
      expect(AStringLikeClass.new('abc').bytes).to eq([97, 98, 99])
    end
  end
end
