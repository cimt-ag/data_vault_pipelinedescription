--DROP function  libdwh.dvf_encrypt(varchar,varchar);

CREATE OR REPLACE FUNCTION libdwh.dvf_encrypt(text_to_encrypt varchar,key_inBase64 varchar) RETURNS varchar AS
$$
begin
    RETURN  encode(encrypt(decode(text_to_encrypt,'escape'),decode(key_inBase64,'base64'),'aes-ecb'),'base64');
EXCEPTION WHEN others THEN
    RETURN NULL;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;


COMMENT ON FUNCTION libdwh.dvf_encrypt(varchar,varchar) IS 'Encrypts data, according to cimt data vault framework GDPR concept AES128-ECB. Arguments: (value,key). The key must be encoded in base64 as varchar';



-- select libdwh.dvf_encrypt('Congratulation, decryption was successful','doT4HVzQbPyBzsF9idG1vA==');
