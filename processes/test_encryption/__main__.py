from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from Crypto.Util.Padding import pad,unpad
import base64
import unittest

BS = 16
unpad2 = lambda s: s[0:-ord(s[-1])]


class AESCipher:
    ''' not tested yet
    def encrypt(self, raw):
        raw = pad(raw)
        cipher = AES.new(self.key, AES.MODE_ECB)
        return base64.b64encode(cipher.encrypt(raw))
    '''

    @staticmethod
    def decrypt(enc, key):
        try:
            decodedKey = base64.b64decode(key)
            enc = base64.b64decode(enc)
            cipher = AES.new(decodedKey, AES.MODE_ECB)
        except:
            return '>>Cant decrypt>>'+enc[:15]+'...'
        return unpad(cipher.decrypt(enc),AES.block_size).decode('utf-8')


def dvf_encrypt(data_to_encrypt, key_inBase64):

    encryption_agent = AES.new(base64.b64decode(key_inBase64), AES.MODE_ECB)
    cipher = encryption_agent.encrypt(pad(data_to_encrypt.encode('utf-8'), AES.block_size))

    return base64.b64encode(cipher).decode('utf-8')

#### simple test ###
def test1():

    print("--- TEST 1 (simple) ---")

    input_data = 'secret data 1234'

    key = get_random_bytes(16)
    encryption_agent = AES.new(key, AES.MODE_ECB)
    ciphertext = encryption_agent.encrypt(input_data.encode('ascii'))

    decryption_agent = AES.new(key, AES.MODE_ECB)
    output_data = decryption_agent.decrypt(ciphertext)

    print("output data=>"+output_data.decode('ascii')+"<")

#### reconstrucion of talend java testcase ###
def test2():

    print("--- TEST 2 (reconstruction) ---")

    input_data = 'ABCDEFGHIJKLMNO'
    input_padded=pad(input_data.encode('utf-8'), AES.block_size)
    key_inBase64 = 'iyVf1xYqU92mP/lW2bV/rQ=='

    print("input_data = >"+input_data+"<")

    print("input_padded = >"+input_padded.hex()+"<")

    key = get_random_bytes(16)
    encryption_agent = AES.new(base64.b64decode(key_inBase64), AES.MODE_ECB)
    cipher = encryption_agent.encrypt(input_padded)
    cipher_inBase64=base64.b64encode(cipher)
    print("cipher_inBase64 = >"+cipher_inBase64.decode('utf-8')+"<")

    decryption_agent = AES.new(base64.b64decode(key_inBase64), AES.MODE_ECB)
    output_data = decryption_agent.decrypt(base64.b64decode(cipher_inBase64))

    print("output data = >"+unpad(output_data, AES.block_size).decode('utf-8')+"<")


### exasol class
def test3():
    print("--- TEST 3 ( Exasol class) ---")

    ciphertext_inBase64 = '6B5cCoMCv8jotJLiFA2Wtw=='
    key_inBase64 = 'iyVf1xYqU92mP/lW2bV/rQ=='

    decrypt_result= AESCipher.decrypt(ciphertext_inBase64, key_inBase64 )

    print("decrypt_result = >"+decrypt_result+"<")


### compatibilty test with talend aes
def test4():
    print("--- TEST 4 (using talend Values) ---")

   # cipher_inBase64 = '6B5cCoMCv8jotJLiFA2Wtw=='
   # key_inBase64 = 'iyVf1xYqU92mP/lW2bV/rQ=='
    cipher_inBase64 = 'O79L/DYW8hPv3MSeEX+3dg=='
    key_inBase64 = 'doT4HVzQbPyBzsF9idG1vA=='

    #key_inBase64 = 'iyVf1xYqU92mP/lW2bV/rQ=='
    #cipher_inBase64 = 'iyx8FtrHaU7T2NB8E2nQAw=='

    cipher=base64.b64decode(cipher_inBase64)
    key=base64.b64decode(key_inBase64)

    decryption_agent = AES.new(key, AES.MODE_ECB)
    output_data = decryption_agent.decrypt(cipher)

    print("output data hex = >"+output_data.hex()+"<")
    print("output data = >"+ unpad(output_data,AES.block_size).decode('ascii')+"<")

def test5():
    print("--- TEST 5 (encrypt) ---")

    data_to_encrypt = "AAA-AAA"
    key_inBase64 = 'doT4HVzQbPyBzsF9idG1vA=='

    cypher = dvf_encrypt(data_to_encrypt,key_inBase64)

    print("output cypher = >"+cypher+"<")

def test6():
    print("--- TEST 6 ( bad decrpyt cases) ---")

    ciphertext_inBase64 = '6B5cCoMCv8jotJLiFA2Wtw=='
    key_inBase64 = 'Bad key'

    decrypt_result = AESCipher.decrypt(ciphertext_inBase64, key_inBase64)

    print("decrypt_result = >" + decrypt_result + "<")

    ciphertext_inBase64 = 'Bad cipher'
    key_inBase64 = 'iyVf1xYqU92mP/lW2bV/rQ=='

    decrypt_result = AESCipher.decrypt(ciphertext_inBase64, key_inBase64)

    print("decrypt_result = >" + decrypt_result + "<")

class Test(unittest.TestCase):
    # key as base64
    key = '3xx5X/ER5MEOfVKwr/ZC2Q=='
    # Test
    encString = 'eNr5fazs/okOF6c0ylUasA=='

    # 100.5
    encDouble = 'w7Xm1QwauRJiGC7fgo6ppw=='

    # true
    encTrue = '2SAAKNNlwrC8QwMD30MWcg=='

    # false
    encFalse = '4sh4IH+wc/YX5zMgPtoZng=='

    # 13228493483.587345123291015625
    encDecimal = 'vo7yW8mMkPAmWVv/z6A4NykZ85ozWxHDJfzak4R6m/I='

    # 2018-06-14 08:10:15.601
    encDate = '21AqClfqCikcUO2KOEBfXsxFfnErsID1t/Q/9eKVDeA='

    def testName(self):
        dec = AESCipher.decrypt(self.encString, self.key)
        self.assertEqual('Test', dec)

        dec = AESCipher.decrypt(self.encDouble, self.key)
        self.assertEqual('100.5', dec)

        dec = AESCipher.decrypt(self.encTrue, self.key)
        self.assertEqual('true', dec)

        dec = AESCipher.decrypt(self.encFalse, self.key)
        self.assertEqual('false', dec)

        dec = AESCipher.decrypt(self.encDecimal, self.key)
        self.assertEqual('13228493483.587345123291015625', dec)

        dec = AESCipher.decrypt(self.encDate, self.key)
        self.assertEqual('2018-06-14 08:10:15.601', dec)

        pass


if __name__ == "__main__":
    test1()
    test2()
    test3()
    test4()
    test5()
    test6()
    unittest.main()


