from AES import *

myDES = AES();

plaintext = '3243f6a8885a308d313198a2e0370734';
key       = '2b7e151628aed2a6abf7158809cf4f3c';

ciphertext = myAES.encrypt(plaintext, key)
#decrypted  = myAES.decrypt(ciphertext,key)

#print('##########')
#print('key        = ' + key       )
#print('ciphertext = ' + ciphertext)
#print('plaintext  = ' + plaintext )
#print('decrypted  = ' + decrypted )

