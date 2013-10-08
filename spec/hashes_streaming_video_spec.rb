require_relative '../hashes_streaming_video'
describe HashesStreamingVideo do
  it "can calculate the correct hash for a video" do
    hash = subject.hash_file('test_video.mp4')

    expect(hash).to eq("03c08f4ee0b576fe319338139c045c89c3e8e9409633bea29442e21425006ea8")
  end
end
