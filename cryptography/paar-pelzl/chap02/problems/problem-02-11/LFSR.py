from numpy import array
from numpy.core import *
from numpy.linalg import *

class LFSR:
	def __init__(self):
		self.alphabet = [
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
			'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
			'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5'
			]

		self.charToBits = dict()
		for i in range(0,len(self.alphabet)):
			self.charToBits[self.alphabet[i]] = bin(i).replace('0b','')

	def getChar(self,x):
		return self.alphabet[x]

	def getBit(self,x):
		return self.charToBits[x.lower()]

	def text2bits(self,inputText):
		outputBits = ''
		for char in list(inputText):
			outputBits = outputBits + self.getBit(char)
		return outputBits

	def addBits(self,x,y):
		temp = min(len(x),len(y)) * [-1];
		for i in range(0,len(temp)):
			temp[i] = bin((int(x[i]) + int(y[i])) % 2).replace('0b','')
		return(''.join(temp))

	def toRowVector(self,x):
		return(array(map(int,list(x))))

	def getCoefficientMatrix(self,keystream,period):
		print('keystream')
		print( keystream )
		outputMatrix = array([[-1]*period]*period)
		for i in range(period):
			#print('keystream[i:(i+period)]')
			#print( keystream[i:(i+period)] )
			#print('self.toRowVector(keystream[i:(i+period)])')
			#print( self.toRowVector(keystream[i:(i+period)]) )
			outputMatrix[i,:period] = self.toRowVector(keystream[i:(i+period)])
		return outputMatrix

	def getFeedbackCoefficients(self,keystream,period):
		lhs = self.toRowVector(keystream[period:2*period])
		rhs = keystream[0:period]
		myMatrix = self.getCoefficientMatrix(keystream,period)
		#soln = linalg.solve(myMatrix,lhs)
		print('lhs')
		print( lhs )
		print('rhs')
		print( rhs )
		print('myMatrix')
		print( myMatrix )
		print('rank(myMatrix)')
		print( rank(myMatrix) )
		return(1)

	def decrypt(self,ciphertext,plaintextPrefix,period):
		cipherbits = self.text2bits(ciphertext)
		#print('cipherbits')
		#print( cipherbits )
		plainPrefixBits = self.text2bits(plaintextPrefix)
		#print('plainPrefixBits')
		#print( plainPrefixBits )
		keystream = self.addBits(plainPrefixBits,cipherbits)
		#print('keystream')
		#print( keystream )
		#print('')
		#print( cipherbits )
		#print( plainPrefixBits )
		#print( keystream )
		temp = self.getFeedbackCoefficients(keystream,period)
		return 1

