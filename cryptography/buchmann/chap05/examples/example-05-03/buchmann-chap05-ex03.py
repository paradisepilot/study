from DES import *

myDES = DES();

plaintext = '0123456789ABCDEF';
key       = '133457799BBCDFF1';

ciphertext = myDES.encrypt(plaintext, key)
decrypted  = myDES.decrypt(ciphertext,key)

print('##########')
print('key        = ' + key       )
print('ciphertext = ' + ciphertext)
print('plaintext  = ' + plaintext )
print('decrypted  = ' + decrypted )

