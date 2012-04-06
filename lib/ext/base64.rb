module Base64
  def self.strict_encode64(bin)
    [bin].pack("m0")
  end
  def self.strict_decode64(str)
    str.unpack("m0").first
  end

  def self.urlsafe_encode64(bin)
    strict_encode64(bin).tr("+/", "-_").gsub(/=+$/, '').gsub("\n", '')
  end
  def self.urlsafe_decode64(str)
    str = string_multiple_or_pad(str, 4, '=')
    s64 = strict_decode64(str.tr("-_", "+/"))
  end
  
  def self.padlen_for_multiple(str, n)
    remainder = str.size % n
    (n - remainder) % n
  end

  def self.string_multiple_or_pad(str, n, pad)
    padlen = padlen_for_multiple(str, n)
    str += padlen.times.map {pad}.join
  end
end

class UriSafe

  CHARACTER_MAPPING = {
    '+' => '-',
    '/' => '_'
  }

  def self.encode(input)
    CHARACTER_MAPPING.inject(input) do |s, pair|
      decoded, encoded = pair
      s.gsub(decoded, encoded)
    end
  end

  def self.decode(input)
    CHARACTER_MAPPING.inject(input) do |s, pair|
      decoded, encoded = pair
      s.gsub(encoded, decoded)
    end
  end
end