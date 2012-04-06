require 'spec_helper'

require './lib/msp_tokenize'

describe "Tokenize" do
  
  before :all do
    @hmac = "g4ILzF0C5HjuO803lIFlZNp8VmWAdmiu7Zn0EkYbZ48neEfpFSfl6z7XRL0rGIuz"
    @aes =  "\306Y\232\002J\315HAK\216G<8\216\360\223" 
    @data_s = "This statement is false. The cake is a lie! How are you? - Because Im a potato!"
    @data = {'userId' => 'tom', 'my_info' => 'foobarbaz'}
    @iv =  "6TQ9JLFYe_buCeQTcTk8Ng" #"WQ\2276\036\3243\270X\005\254\203C\f|\351"
 
    @token = Token.new(@hmac, @aes)
  end
  
  context 'Encode & Decode' do
    it 'should produce the same output as input' do
      t_encoded = @token.encode(@data, @iv, false, nil)
      t_encoded.should_not == nil
      t_decoded = @token.decode(t_encoded[0], t_encoded[1])
      t_decoded.should == @data
      # this will also be testing the timstamp passes as part of it.
    end
    
    it 'should produce the url params in the correct format' do
      url = @token.encode(@data, @iv, true)
      url.should =~ /(.*)\?token=(.*)&iv=(.*)/
    end
    
    it 'should error on outdated timestamps' do
      t_encoded = @token.encode(@data, @iv, false, "#{(Time.now - 10000).strftime('%Y%m%d%H%M%S001')}")
      t_encoded.should_not == nil
      t_decoded = @token.decode(t_encoded[0], t_encoded[1])
      t_decoded.should == "time failure"
    end

  end
  
  context 'Expected output for examples' do
    
    it 'login should DECODE' do
      token = "hTleTR0kIsDh07tdgVXogYoaF0os4WIJiJskQjYRz_88xg4rgwiP53vnl27KPMEEwBcz16PpalwsMn5bkJzoWbxXXY1_7GlftJdSmV6otVop3VCdfmU-cWYE8y8K2GWe"
      iv = "XwgtG1_nRxM7RU53c2ISNA"
      expected = {"outcome"=>"login", "userId"=>"111720009"}
      decoded = @token.decode(token, iv, true)
      decoded.should == expected
    end
    
    it 'login-cancel DECODE' do
      token = "DgmCI76kxL2TID-QwgwW_7uWxiFLEq0u4No1JANpYfiKs_Ve_g7DM5Cc4JGRaRf2rP7mlbbpLfSHbbF7_iwKx0VxE6TOAtJfxL926TOBjHg"
      iv = "ogs0DZCYhcsP-iAM0kNwIQ"
      expected = {"outcome" => "cancel"}
      decoded = @token.decode(token, iv, true)
      decoded.should == expected
    end
    
    
    it 'login-with-random-data should give expected e.g.' do
      token = "S5AHh13RhwGL8M29VrEovI7Y8iioGbCUx3UWXbxnjp2Pk6971G1fOzPYJqi1wXUZOS20yG_iKa9Loz38NCBcZPZQ4hk4X6TBi8UOa3soqrYMxmWKnxkMpbeiu3dixXDYuOmpJPOxtq_NcHbIirs8EEAhRIBVl0kxgmLYGc3YQeoHr_H9KWMb5NUR7MjBzs7Ym6BRQfWnvEpv8F3HOVKtvg"
      iv = "rUMhohRfAkYsKAHRLtzIhQ"   
      expected = {
      "outcome" => "login",
      "hello" => "world",
      "cats" => "dogs",
      "somethingLonger"=>"0123456789qrstuvwxyz9876543210**##++etc"}
      decoded = @token.decode(token, iv, true)
      decoded.should == expected
    end
    
    
    it 'data from spec' do
      token = "hCqZp4ReciOAyuP-AuHuDFe2oqC7AVo75e8xtq-lNe17ROHiLhpY9RhkOduWT4cEjaUiLaW6E3dZU1IBrBpyCI_ZifCjPYXy_WCMBLqEOB0"
      iv = "h7lugaFPUXRdgADtOlF6Kg"
      expected = {"Timestamp"=>"20110901170705346", "digest"=>"hXwCB/PgrWYDhLjLLOMaxZSy5Z4", "UserId"=>"123456"}
      decoded = @token.decode(token, iv, true)
      decoded.should == "digest mismatch"
    end
  end
end