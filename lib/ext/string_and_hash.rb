class String
  def url_params_to_hash
    data_hash = {}
    self.split('&').each do |i|
      k,v = i.split('=')
      data_hash[k] = v
    end
    return data_hash
  end
  
  def pad_to_length(char, len)
    (self + ("#{char}" * (len % self.size)))
  end
end

class Hash  
  def to_url_params
    self.map { |i| i.join('=') }.join('&')
  end
end