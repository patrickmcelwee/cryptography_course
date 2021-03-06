require_relative '../key'
require 'xorable_class_spec'
require 'string_like_class_spec'

describe Key do
  subject {Key.new('abc')}

  it_behaves_like "an_xorable_class"
  it_behaves_like "a string-like class"

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
