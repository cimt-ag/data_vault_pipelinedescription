
--drop function libdwh.dvf_encrypt(varchar,varchar);

CREATE OR REPLACE FUNCTION libdwh.dvf_encrypt(data_to_encrypt varchar,key_inBase64 varchar)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = 3.8
PACKAGES = ('pycryptodome')
HANDLER = 'dvf_encrypt'
AS $$
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from Crypto.Util.Padding import pad,unpad
import base64
def dvf_encrypt(data_to_encrypt, key_inBase64):

    encryption_agent = AES.new(base64.b64decode(key_inBase64), AES.MODE_ECB)
    cipher = encryption_agent.encrypt(pad(data_to_encrypt.encode('utf-8'), AES.block_size))

    return base64.b64encode(cipher).decode('utf-8')
$$;





COMMENT ON FUNCTION libdwh.dvf_encrypt(varchar,varchar) IS 'Ecrypts data, according to data vault GDPR concept AES128-ECB. Arguments: (value,key). The key must be encoded in base64 as varchar';

/* select libdwh.dvf_encrypt('Congratulation, decryption was successful','doT4HVzQbPyBzsF9idG1vA==');
*/