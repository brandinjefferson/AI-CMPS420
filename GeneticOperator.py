import random
import string

alphabet = string.letters

class Chromosome:
	def __init__(self):
		self.bits = []
		self.fitness = 0
		
	def evalFitness(self,expression,vars):
		bit_str = ""
		activeNot = False
		for x in expression:
			if x not in (alphabet + "!"):
				if x != "*":
					bit_str += x
					if x == ")":
						result = eval(bit_str)
						if result > 0:
							self.fitness+=1
						bit_str=""
			else:
				if x == "!":
					activeNot = True
				else:
					if activeNot:
						if self.bits[vars.index(x)] == 0:
							bit_str += "1"
						else:
							bit_str += "0"
						activeNot = False
					else:
						bit_str += self.bits[vars.index(x)]
						
	def isSolution(self,numVars):
		return self.fitness == numVars
	
	def setBits(self,numVars):
		for x in range(0,numVars):
			self.bits.append(random.randint(0,1))

	def mutate(self):
		index = random.randint(0,len(self.bits))
		if self.bits[index] == 0:
			self.bits[index] = 1
		else:
			self.bits[index] = 0
#----End Class

#Create new children
def geneticOperations(numVars,c1,c2):
	#while max <= 25, keep doing crossovers
	min = 0
	max = random.randint(1,numVars)
	while max <= numVars:
		part1 = c1.bits[min:max]
		part2 = c2.bits[min:max]
		c1.bits[min:max] = part2
		c2.bits[min:max] = part1
		min = max+1
		max = random.randint(min,numVars)
	mutate = random.randint(0,1)
	if mutate == 1:
		c1.mutate()
		c2.mutate()
		



continue_prog = "y"

print "The following program takes an expression in conjunctive normal form"
print "and returns a combination of bits such that the expression evaluates"
print "to true."
print "+ := OR"
print "* := AND"
print "! := NOT"

expr = raw_input("Enter Expression: ")

while continue_prog == "y" or continue_prog == "yes"
	#Parse string and get unique variables
	var_list = []		#A list of the vars in the expression
	for x in expr:
		#in and not in check single character strings to see if they're in 
		#the list
		if x in alphabet and x not in expr_list:
			var_list.append(x)
	numVars = len(var_list)
	
	#Generate initial population (create random bits for each variable)
	c1 = Chromosome()
	c1.setBits(numVars)
	c1.evalFitness(numVars)
	c2 = Chromosome()
	c2.setBits(numVars)
	c2.evalFitness(numVars)
	c3 = Chromosome()
	c3.setBits(numVars)
	c3.evalFitness(numVars)
	c4 = Chromosome()
	c4.setBits(numVars)
	c4.evalFitness(numVars)
	
	
	#Perform genetic algorithm until problem is solved
	solved = False
	while solved != True:
		#Eval members of the population
		if evalChromosome(expr,bit_list1,var_list):
			solved = True
			print "The first solution found is %s" %str(bit_list1)
		elif evalChromosome(expr,bit_list2,var_list):
			solved = True
			print "The first solution found is %s" %str(bit_list2)
		else:
			#Produce the offspring using crossover points
			
	
	
			