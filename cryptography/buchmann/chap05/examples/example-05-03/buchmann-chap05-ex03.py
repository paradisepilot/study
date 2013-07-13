from DES import *

myDES = DES();

plaintext = '0123456789ABCDEF';
key       = '133457799BBCDFF1';

ciphertext      = 'j5a0edj2b'
plaintextPrefix = 'wpi'
period          = 6

ciphertext = myDES.encrypt(plaintext,key)

