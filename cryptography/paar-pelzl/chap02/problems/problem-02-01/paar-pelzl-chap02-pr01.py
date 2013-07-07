
letters2Digits = dict(
	a =  0, b =  1, c =  2, d =  3, e =  4, f =  5, g =  6, h =  7, i =  8, j =  9,
	k = 10, l = 11, m = 12, n = 13, o = 14, p = 15, q = 16, r = 17, s = 18, t = 19,
	u = 20, v = 21, w = 22, x = 23, y = 24, z = 25
	)

alphabet = [
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
	'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
	'u', 'v', 'w', 'x', 'y', 'z'
	]

def toDigits(inputText,dictionaryLetters2Digits):
	y = []
	for z in inputText.lower():
		y.append(dictionaryLetters2Digits[z])
	return(y)

def encrypt(plaintext,inputKey,dictionaryLetters2Digits,alphabet):
	digitizedKey        = toDigits(inputKey,         dictionaryLetters2Digits)
	digitizedCiphertext = toDigits(plaintext.lower(),dictionaryLetters2Digits)
	ciphertext = []
	for i in range(0,len(plaintext)):
		tempIndex = (digitizedCiphertext[i] + digitizedKey[i % len(digitizedKey)]) % 26
		ciphertext.append(alphabet[tempIndex])
	ciphertext = ''.join(ciphertext)
	return(ciphertext)

def decrypt(ciphertext,inputKey,dictionaryLetters2Digits,alphabet):
	digitizedKey        = toDigits(inputKey,  dictionaryLetters2Digits)
	digitizedCiphertext = toDigits(ciphertext,dictionaryLetters2Digits)
	plaintext = []
	for i in range(0,len(ciphertext)):
		tempIndex = (digitizedCiphertext[i] - digitizedKey[i % len(digitizedKey)]) % 26
		plaintext.append(alphabet[tempIndex])
	plaintext = ''.join(plaintext)
	return(plaintext)

####################################################################################################
ciphertext = "bsasppkkuosp"
key        = "rsidpydkawoa"

plaintext = decrypt(ciphertext,key,letters2Digits,alphabet)
print('plaintext');
print( plaintext );

testMessage = 'JefferyStraker'
temp = encrypt(testMessage,key,letters2Digits,alphabet)
print('\nencrypted test message:');
print( temp );

temp = decrypt(temp,key,letters2Digits,alphabet)
print('\ndecrypted test message:');
print( temp );

