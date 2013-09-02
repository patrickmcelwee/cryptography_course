shared_examples "an_xorable_class" do
  subject {described_class.new('abc')}

  it "responds to #bytes" do
    expect(subject).to respond_to(:bytes)
  end

  it "responds to #^" do
    expect(subject).to respond_to(:^)
  end

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
