require "tokenize/version"
require 'yaml'
require 'base64'
require 'digest'
require 'openssl'
require 'ext/base64'
require 'ext/string_and_hash'



module MSPTokenize; end

# does all the work do TOKEN = Token.new(hmac, aes).
# then TOKEN.encode(my_data) / TOKEN.decode(token, iv)
# see README for detailed info.
class Token

  CYPHER_TYPE = "AES-128-CBC"

  def initialize(hmac, aes)
    @hmac = hmac
    @aes  = aes
  end
  attr_accessor :hmac, :aes

  def encode(data, iv = nil, as_url = false, timestamp = nil)
    iv ||= generate_iv
    unless data.is_a?(Hash)
      raise "give me a hash"
      return
    end
    data = data.to_url_params
    if !timestamp.nil?
      data += "&timestamp=#{timestamp}"
    else
      data += "&timestamp=#{Time.now.strftime('%Y%m%d%H%M%S001')}"
    end

    digest =  Base64.urlsafe_encode64(OpenSSL::HMAC.digest('sha1', self.hmac, data))
    token = "#{data}&hash=#{digest}"
    encrypted_token = aes_encrypt(token, Base64.urlsafe_decode64(iv))
    encrypted_token = Base64.urlsafe_encode64(encrypted_token)
    if as_url
      return "?token=#{encrypted_token}&iv=#{iv}"
    else
      return [encrypted_token, iv]
    end
  end

  def decode(token, iv_encoded, skip_ts_check = false)
    token = Base64.urlsafe_decode64(token)
    padded_iv = iv_encoded.pad_to_length("=",24)
    iv = Base64.urlsafe_decode64(padded_iv)
    decrypted_token = aes_decrypt(token, iv)
    data_for_digest = decrypted_token
    digest = decrypted_token.url_params_to_hash['hash']
    d = decrypted_token.url_params_to_hash
    data_for_digest.gsub!(/&hash=(.*)/, '')
    digest_check = Base64.urlsafe_encode64(OpenSSL::HMAC.digest('sha1', self.hmac, data_for_digest))
    unless digest == digest_check
      return "digest mismatch"
    end
    unless skip_ts_check
      time = decrypted_token.url_params_to_hash['timestamp']
      time = Time.utc(time[0..3].to_s, time[4..5], time[6..7], time[8..9], time[10..11], time[12..13], time[14..16])
      if time <= (Time.now - 3600) || time > Time.now # older than 1hr ago || future!
        return "time failure"
      end
    end

    data = data_for_digest.gsub(/&timestamp=(.*)/, '')
    return data.url_params_to_hash
  end

  # private
    def aes_encrypt(data, iv)
      aes = OpenSSL::Cipher.new(CYPHER_TYPE)
      aes.encrypt
      aes.key = self.aes
      aes.iv = iv
      aes.update(data) + aes.final
    end

    def aes_decrypt(encrypted_data, iv)
      aes = OpenSSL::Cipher.new(CYPHER_TYPE)
      aes.decrypt
      aes.key = self.aes
      aes.iv = iv
      aes.update(encrypted_data) + aes.final
    end

    def generate_iv
      aes = OpenSSL::Cipher.new(CYPHER_TYPE)
      x = aes.random_iv
      return Base64.urlsafe_encode64(x)
    end
end