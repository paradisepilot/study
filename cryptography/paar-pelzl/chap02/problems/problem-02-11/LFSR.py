from numpy import matrix
from numpy.core import *
from numpy.linalg import *

class LFSR:
	def __init__(self):
		self.numOfBits = 5

		self.alphabet = [
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
			'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
			'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5'
			]

		self.bitStrings = dict()
		for i in range(0,len(self.alphabet)):
			self.bitStrings[self.alphabet[i]] = bin(i).replace('0b','').zfill(self.numOfBits)

		self.characters = dict()
		for i in range(0,len(self.alphabet)):
			self.characters[self.bitStrings[self.alphabet[i]]] = self.alphabet[i]

	def getAlphabet(self):
		return(self.alphabet)

	def getBitStrings(self):
		return(self.BitStrings)

	def getChar(self,x):
		return self.alphabet[x]

	def getBit(self,x):
		return self.bitStrings[x.lower()]

	def text2bits(self,inputText):
		outputBits = ''
		for char in list(inputText):
			outputBits = outputBits + self.getBit(char)
		return outputBits

	def bits2text(self,plaintextbits):
		plaintextLength = len(plaintextbits) / self.numOfBits
		plaintext = ['a'] * plaintextLength
		for i in range(0,plaintextLength):
			tempBitString = plaintextbits[(i*self.numOfBits):((i+1)*self.numOfBits)]
			plaintext[i] = self.characters[tempBitString]
		return(''.join(plaintext))

	def addBits(self,x,y):
		temp = min(len(x),len(y)) * [-1];
		for i in range(0,len(temp)):
			temp[i] = bin((int(x[i]) + int(y[i])) % 2).replace('0b','')
		return(''.join(temp))

	def toRowVector(self,x):
		return(map(int,list(x)))

	def toColumnVector(self,x):
		return(matrix(map(int,list(x))).transpose())

	def getCoefficientMatrix(self,keystream,period):
		outputMatrix = matrix([[-1]*period]*period)
		for i in range(period):
			outputMatrix[i,:period] = self.toRowVector(keystream[i:(i+period)])
		return outputMatrix

	def mod2(self,x):
		return(int(round(x)) % 2)

	def getFeedbackCoefficients(self,keystream,period):
		myLHS    = self.toColumnVector(keystream[period:2*period])
		myMatrix = self.getCoefficientMatrix(keystream,period)
		soln     = map(self.mod2,linalg.solve(myMatrix,myLHS))
		return(soln)

	def getKeyStream(self,initialKeyStream,feedbackCoefficients,length):
		period    = len(initialKeyStream)
		keystream = [-1] * length
		keystream[0:period] = map(int,list(initialKeyStream))
		for i in range(period,len(keystream)):
			keystream[i] = sum(keystream[(i-period):i] * array(feedbackCoefficients)) % 2
		return(''.join(map(str,keystream)))

	def decrypt(self,ciphertext,plaintextPrefix,period):
		cipherbits      = self.text2bits(ciphertext)
		plainPrefixBits = self.text2bits(plaintextPrefix)

		initialKeyStream     = self.addBits(plainPrefixBits,cipherbits)
		feedbackCoefficients = self.getFeedbackCoefficients(initialKeyStream,period)
		keystream            = self.getKeyStream(initialKeyStream[0:period],feedbackCoefficients,len(cipherbits))
		
		plaintextbits = self.addBits(keystream,cipherbits)
		plaintext     = self.bits2text(plaintextbits)

		return(plaintext)

