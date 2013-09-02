shared_examples 'a string-like class' do
  it "responds to #to_s" do
    expect(subject).to respond_to(:to_s)
  end

  it "responds to #length" do
    expect(subject).to respond_to(:length)
  end

  it "responds to #bytes" do
    expect(subject).to respond_to(:bytes)
  end
end
