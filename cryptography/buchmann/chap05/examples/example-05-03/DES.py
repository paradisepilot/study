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

		self.bitStrings = dict()
		for i in range(0,len(self.alphabet)):
			self.bitStrings[self.alphabet[i]] = bin(i).replace('0b','').zfill(self.numOfBits)

		self.characters = dict()
		for i in range(0,len(self.alphabet)):
			self.characters[self.bitStrings[self.alphabet[i]]] = self.alphabet[i]

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

		self.InternalExpansionVector = [
			32, 1, 2, 3, 4, 5,
			 4, 5, 6, 7, 8, 9,
			 8, 9,10,11,12,13,
			12,13,14,15,16,17,
			16,17,18,19,20,21,
			20,21,22,23,24,25,
			24,25,26,27,28,29,
			28,29,30,31,32, 1
			]

		self.FeistelPC1Vector = [
			57,49,41,33,25,17, 9,
			 1,58,50,42,34,26,18,
			10, 2,59,51,43,35,27,
			19,11, 3,60,52,44,36,
			63,55,47,39,31,23,15,
			 7,62,54,46,38,30,22,
			14, 6,61,53,45,37,29,
			21,13, 5,28,20,12, 4
			]

		self.FeistelPC2Vector = [
			14,17,11,24, 1, 5, 3,28,
			15, 6,21,10,23,19,12, 4,
			26, 8,16, 7,27,20,13, 2,
			41,52,31,37,47,55,30,40,
			51,45,33,48,44,49,39,56,
			34,53,46,42,50,36,29,32
			]

		self.InternalPermutationVector = [
			16, 7,20,21,29,12,28,17,
			 1,15,23,26, 5,18,31,10,
			 2, 8,24,14,32,27, 3, 9,
			19,13,30, 6,22,11, 4,25
			]

		self.InternalSBoxes = [
			# S1
			matrix([
				[14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7],
				[0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8],
				[4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0],
				[15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13]
				]),
			# S2
			matrix([
				[15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10],
				[3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5],
				[0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15],
				[13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9]
				]),
			# S3
			matrix([
				[10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8],
				[13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1],
				[13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7],
				[1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12]
				]),
			# S4
			matrix([
				[7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15],
				[13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9],
				[10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4],
				[3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14]
				]),
			# S5
			matrix([
				[2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9],
				[14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6],
				[4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14],
				[11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3]
				]),
			# S6
			matrix([
				[12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11],
				[10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8],
				[9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6],
				[4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13]
				]),
			# S7
			matrix([
				[4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1],
				[13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6],
				[1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2],
				[6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12]
				]),
			# S8
			matrix([
				[13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7],
				[1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2],
				[7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8],
				[2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11]
				])
			]

		self.leftShiftVector = [2] * self.numOfRounds
		self.leftShiftVector[ 0] = 1
		self.leftShiftVector[ 1] = 1
		self.leftShiftVector[ 8] = 1
		self.leftShiftVector[15] = 1

	def getAlphabet(self):
		return(self.alphabet)

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

	#def toRowVector(self,x):
	#	return(map(int,list(x)))

	#def toColumnVector(self,x):
	#	return(matrix(map(int,list(x))).transpose())

	#def mod2(self,x):
	#	return(int(round(x)) % 2)

	def encrypt(self,plaintext,key):
		plainbits    = self.text2bits(plaintext)
		roundKeys    = self.getRoundKeys(key,self.leftShiftVector)
		permutedBits = self.initialPermutation(plainbits)
		cipherbits   = self.FeistelCipher(permutedBits,roundKeys)
		print('plainbits')
		print( plainbits )
		print('permutedBits')
		print( permutedBits )
		print('cipherbits')
		print( cipherbits )
		#keybits = self.text2bits(key)
		#print('keybits');
		#print( keybits );
		#for i in range(0,len(roundKeys)):
		#	print('i = ' + str(i) + ', roundKey = ' + roundKeys[i])
		return(plainbits)

	def initialPermutation(self,bitString):
		return(''.join([bitString[i-1] for i in self.initialPermutationVector]))

	# Feistel Cipher
	def FeistelCipher(self,bitString,roundKeys):
		tempL = ''.join([bitString[i] for i in range(0,len(bitString)/2)])
		tempR = ''.join([bitString[i] for i in range(len(bitString)/2,len(bitString))])
		for roundIndex in range(0,self.numOfRounds):
			tempL1 = tempL
			tempL  = tempR
			tempR  = self.addBits(tempL1,self.InternalCipher(tempR,roundKeys[roundIndex]))
			print('i = ' + str(roundIndex) + ', R = ' + tempR)
		return(tempR + tempL)

	def FeistelPC1(self,bitString):
		return(''.join([bitString[i-1] for i in self.FeistelPC1Vector]))

	def FeistelPC2(self,bitString):
		return(''.join([bitString[i-1] for i in self.FeistelPC2Vector]))

	def getRoundKeys(self,key,leftShiftVector):
		tempCD     = self.FeistelPC1(self.text2bits(key))
		tempLength = len(tempCD)/2
		roundKeys = [-1]*self.numOfRounds
		for i in range(0,self.numOfRounds):
			tempC  = [tempCD[j] for j in range(0,tempLength)]
			tempD  = [tempCD[j] for j in range(tempLength,2*tempLength)]
			tempC  = [tempC[(j+leftShiftVector[i]) % tempLength] for j in range(0,tempLength)]
			tempD  = [tempD[(j+leftShiftVector[i]) % tempLength] for j in range(0,tempLength)]
			tempCD = tempC + tempD
			roundKeys[i] = self.FeistelPC2(''.join(tempCD))
		return(roundKeys)

	# Internal Cipher
	def InternalCipher(self,bitString,roundKey):
		temp = self.addBits(self.InternalExpand(bitString),roundKey)
		temp = self.InternalApplySBoxes(temp,self.InternalSBoxes)
		temp = self.InternalPermute(temp)
		#print('InternalEncrypt')
		#print( temp )
		return(temp)

	def InternalExpand(self,bitString):
		return(''.join([bitString[i-1] for i in self.InternalExpansionVector]))

	def InternalPermute(self,bitString):
		return(''.join([bitString[i-1] for i in self.InternalPermutationVector]))

	def InternalApplySBoxes(self,bitString,SBoxes):
		tempC = ''
		for i in range(0,8):
			tempB = ''.join([bitString[j] for j in range(6*i,6*(i+1))])
			tempX = int(tempB[0]+tempB[5],2)
			tempY = int(tempB[1:5],2)
			tempC = tempC + bin(self.InternalSBoxes[i][tempX,tempY]).replace('0b','').zfill(4)
		return(tempC)

