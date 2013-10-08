require 'digest'

class HashesStreamingVideo
  def hash_file(file_name)
    do_hash(file_name).unpack('H*').first
  end

  def do_hash(file_name)
    File.open(file_name) do |f|
      f.each_byte.each_slice(1024).reverse_each.inject(nil) do |hash, block|
        block = block.pack('C*')
        block << hash if hash
        Digest::SHA2.digest(block)
      end
    end
  end
end
