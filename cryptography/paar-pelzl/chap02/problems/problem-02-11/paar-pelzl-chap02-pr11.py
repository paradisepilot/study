from LFSR import *

y = LFSR();

#for char in y.getAlphabet():
#	print( char + ': ' + y.getBit(char) )

ciphertext      = 'j5a0edj2b'
plaintextPrefix = 'wpi'
period          = 6

plaintext = y.decrypt(ciphertext,plaintextPrefix,period)

print('')
print('plaintext: ' + plaintext );
print('')

