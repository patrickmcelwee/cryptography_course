class Message
  attr_reader :presently_known

  def self.from_cipher(cipher)
    presently_known = '?' * cipher.length
    new(presently_known)
  end

  def initialize(presently_known)
    @presently_known = presently_known
  end

  def to_s
    presently_known
  end
end
