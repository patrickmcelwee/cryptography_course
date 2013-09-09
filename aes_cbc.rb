class AesCbc
  def initialize(string, input_encoding: :ascii, output_encoding: :ascii,
                 key:  ->{raise "needs a key"}.call)
    @string = normalize_input string, input_encoding
    @output_encoding = output_encoding
  end

  def encrypt
    normalize_output string, output_encoding
  end

  def decrypt
    normalize_output string, output_encoding
  end

  private
  attr_reader :string, :output_encoding

  def normalize_input(input, input_encoding)
    case input_encoding
    when :ascii
      input
    when :hex
      input.scan(/../).map { |x| x.hex }.pack('C*')
    else
      raise "Not a known encoding: #{input_encoding}"
    end
  end

  def normalize_output(output, output_encoding)
    case output_encoding
    when :ascii
      output
    when :hex
      output.unpack('H*').first
    else
      raise "Not a known encoding: #{input_encoding}"
    end
  end
end
