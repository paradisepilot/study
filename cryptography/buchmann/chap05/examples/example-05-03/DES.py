from numpy import matrix
from numpy.core import *
from numpy.linalg import *

class DES:
	def __init__(self):
		self.numOfBits   =  4
		self.numOfRounds = 16

		self.alphabet = [
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
			'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
			'U', 'V', 'W', 'X', 'Y', 'Z'
			]

		self.initialPermutationVector = [
			58,50,42,34,26,18,10, 2,
			60,52,44,36,28,20,12, 4,
			62,54,46,38,30,22,14, 6,
			64,56,48,40,32,24,16, 8,
			57,49,41,33,25,17, 9, 1,
			59,51,43,35,27,19,11, 3,
			61,53,45,37,29,21,13, 5,
			63,55,47,39,31,23,15, 7
			]

		self.finalPermutationVector = [
			40, 8,48,16,56,24,64,32,
			39, 7,47,15,55,23,63,31,
			38, 6,46,14,54,22,62,30,
			37, 5,45,13,53,21,61,29,
			36, 4,44,12,52,20,60,28,
			35, 3,43,11,51,19,59,27,
			34, 2,42,10,50,18,58,26,
			33, 1,41, 9,49,17,57,25
			]

		self.FeistelExpansionVector = [
			32, 1, 2, 3, 4, 5,
			 4, 5, 6, 7, 8, 9,
			 8, 9,10,11,12,13,
			12,13,14,15,16,17,
			16,17,18,19,20,21,
			20,21,22,23,24,25,
			24,25,26,27,28,29,
			28,29,30,31,32, 1
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
		return self.bitStrings[x.upper()]

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

	def encrypt(self,plaintext,key):
		plainbits = self.text2bits(plaintext)
		print('plainbits')
		print( plainbits )
		permutedBits = self.initialPermutation(plainbits)
		print('permutedBits')
		print( permutedBits )
		cipherbits = self.FeistelCipher(permutedBits)
		print('cipherbits')
		print( cipherbits )
		return(plainbits)

	def initialPermutation(self,bitString):
		temp = [bitString[i-1] for i in self.initialPermutationVector]
		return(''.join(temp))

	def FeistelExpand(self,bitString):
		temp = [bitString[i-1] for i in self.FeistelExpansionVector]
		return(''.join(temp))

	def FeistelEncrypt(self,bitString,roundIndex):
		self.FeistelExpand(bitString)
		return(bitString)

	def FeistelCipher(self,bitString):
		tempL = ''.join([bitString[i] for i in range(0,len(bitString)/2)])
		tempR = ''.join([bitString[i] for i in range(len(bitString)/2,len(bitString))])
		for roundIndex in range(0,self.numOfRounds):
			tempL1 = tempL
			tempL  = tempR
			tempR  = self.addBits(tempL1,self.FeistelEncrypt(tempR),roundIndex)
		return(tempR + tempL)

