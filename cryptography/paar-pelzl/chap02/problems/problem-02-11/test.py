from LFSR import *

y = LFSR()

ciphertext      = 'j5a0edj2b'
plaintextPrefix = 'wpi'
period          = 6

plaintext = y.decrypt(ciphertext,plaintextPrefix,period)
print('plaintext');
print( plaintext );

exit();

######################################################################
print("\ny.getBit('Z')")
print(   y.getBit('Z') )

print("\ny.getBit('5')")
print(   y.getBit('5') )

print("\ny.getChar(24)")
print(   y.getChar(24) )

print("\ny.getChar(25)")
print(   y.getChar(25) )

print("\ny.getChar(26)")
print(   y.getChar(26) )

print("\ny.getChar(27)")
print(   y.getChar(27) )

print("\ny.getChar(28)")
print(   y.getChar(28) )

print('')
