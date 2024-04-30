--DROP function  libdwh.dvf_decrypt(varchar,varchar);

CREATE OR REPLACE FUNCTION libdwh.dvf_decrypt(cipher_inBase64 varchar,key_inBase64 varchar) RETURNS varchar AS
$$
begin
    RETURN  encode(decrypt(decode(cipher_inBase64,'base64'),decode(key_inBase64,'base64'),'aes-ecb'),'escape');
EXCEPTION WHEN others THEN
    RETURN '>>Can not decrypt>>'||substr(cipher_inBase64,1,15)||'...';
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;


comment on function libdwh.dvf_decrypt(varchar,varchar) IS 'Decrypts data according to cimt data vault framework GDPR concept AES128-ECB. Arguments: (cipher,key) both encoded in base64 as varchar';



-- select libdwh.dvf_decrypt('PyDkb5oqdWNVXh3b+xEAZly68B1Xy+UymTI/iGpnT+mbUB6hwoskP5Zz2W+UVrBo','doT4HVzQbPyBzsF9idG1vA==');
 
-- select libdwh.dvf_decrypt('PyDkb5oqdWNVXh3b+xEAZly68B1Xy+UymTI/iGpnT+mbUB6hwoskP5Zz2W+UVrBo','Bad Key');

-- select libdwh.dvf_decrypt('Bad cipher','doT4HVzQbPyBzsF9idG1vA==');


      
