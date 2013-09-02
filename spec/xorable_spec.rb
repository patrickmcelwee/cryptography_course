require_relative '../lib/xorable'

class AnXorableClass
  include Xorable

  def bytes
    [97, 98, 99]
  end
end

describe Xorable do
  subject {AnXorableClass.new}

  context '^' do
    it "xors its own ascii bytes with the target's ascii bytes" do
      expect(subject ^ 'Y$+').to eq('8FH')
      expect(subject ^ 'aBz').to eq("\x00 \x19")
    end

    it "works when it is longer than target" do
      expect(subject ^ '12').to eq("PP")
    end

    it "works when target is longer" do
      expect(subject ^ '2345678').to eq("SQW")
    end
  end
end
