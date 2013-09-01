require_relative 'key'

describe Key do
  context 'self#for_ciphers' do
    it "returns ?'s for the max length of the ciphers" do
      comm1 = '123'
      comm2 = '1234'
      comm3 = '12'
      communications = [comm1, comm2, comm3]
      expect(Key.unknown_for_ciphers(communications).to_s).to eq('????')
      expect(Key.unknown_for_ciphers([comm1, comm3]).to_s).to eq('???')
    end
  end
end
