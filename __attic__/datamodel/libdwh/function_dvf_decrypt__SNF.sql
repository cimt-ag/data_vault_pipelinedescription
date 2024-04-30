
--drop function libdwh.dvf_decrypt(varchar,varchar);

CREATE OR REPLACE FUNCTION libdwh.dvf_decrypt(cipher_inBase64 varchar,key_inBase64 varchar)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = 3.8
PACKAGES = ('pycryptodome')
HANDLER = 'dvf_decrypt'
AS $$
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from Crypto.Util.Padding import pad,unpad
import base64
def dvf_decrypt(cipher_inBase64,key_inBase64):
	try:
		cipher=base64.b64decode(cipher_inBase64)
		key=base64.b64decode(key_inBase64)

		decryption_agent = AES.new(key, AES.MODE_ECB)
		output_data = decryption_agent.decrypt(cipher)
	except:
		return '>>Can not decrypt>>'+cipher_inBase64[:15]+'...'
	return unpad(output_data,AES.block_size).decode('utf-8')
$$;



COMMENT ON FUNCTION libdwh.dvf_decrypt(varchar,varchar) IS 'Decrypts dataaccording to cimt data vault framework GDPR concept AES128-ECB. Arguments: (cipher,key) both encoded in base64 as varchar';

/* 
 *   select libdwh.dvf_decrypt('PyDkb5oqdWNVXh3b+xEAZly68B1Xy+UymTI/iGpnT+mbUB6hwoskP5Zz2W+UVrBo','doT4HVzQbPyBzsF9idG1vA==');
 * 
 *   select libdwh.dvf_decrypt('PyDkb5oqdWNVXh3b+xEAZly68B1Xy+UymTI/iGpnT+mbUB6hwoskP5Zz2W+UVrBo','bad key');
 * 
 *   select libdwh.dvf_decrypt('PyBadCypherXh3b+xEAZly68B1Xy+UymTI/iGpnT+mbUB6hwoskP5Zz2W+UVrBo','doT4HVzQbPyBzsF9idG1vA==');
*/