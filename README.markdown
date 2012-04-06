# Tokenize


Using HMAC (sha1), AES ("AES-128-CBC") and IV; tokenize encodes and decodes any data you give it.

## 1) Initialise:

<code>
	TOKEN = Token.new(HMAC_SECRET,AES_SECRET)
</code>

	HMAC_SECRET = "g4ILzF0C5HjuO803lIFlZNp8VmWAdmiu7Zn0EkYbZ48neEfpFSfl6z7XRL0rGIuz" (64 characters)
  AES_SECRET = "\306Y\232\002J\315HAK\216G<8\216\360\223" (16 bytes)


## 2) encode:

<code>
	encoded_token, encoded_iv = TOKEN.encode(my_data, {iv = nil}, {as_url = false}, {timestamp = now})
</code>
	1) Only the 1st arg is required, 'my_data'
	2) You can also provide an 'iv' (initiation vector), if you don't then a random-ish one will be generated for you.
	3) as_url gives you the output as a url param string. e.g. "?token=foo&vi=bar". 
	   - Defaults to FALSE.
	   - TRUE returns an array [0] being the token and [1] being the iv
	4) timestamp - you probably wont want to pass this (unless testing), by default is adds a timestamp param to the token so that the youth of the request can be validated. If you do pass a value it needs to be a string in the format: 'yyyyMMddHHnnssSSS'; 
	
e.g.: 
<code>
	"#{(Time.now - 10000).strftime('%Y%m%d%H%M%S001')}"
</code>


## 3) decode:
<code>
	decoded_data = TOKEN.decode(encoded_token, encoded_iv, {skip_ts = false})
</code>
	setting 'skip_ts = true' will bypass the timestamp validation. Useful for testing, or if the sender is creating queries asynchronously and they're delayed before they arrive.

#### Extras

	if you wanted to you can also call aes encryption directly (but it's mainly a sub):
<code>
	token.aes_encrypt(data, iv)
	or
	aes_decrypt(encrypted_data, iv)
</code>