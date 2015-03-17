"""
Author: Brandin Jefferson (bej0843)
Class: Artificial Intelligence (CMPS420)
Description: Finds the solution to a conjunctive normal form expression
	using a genetic algorithm.
Input: A conjunctive normal form expression composed of single letter variables.
Output: A list of values corresponding to each variable such that the given 
	expression evaluates to true. 
Language: Python 2.7.9
"""

import random
import string
import math

alphabet = string.letters

"""
Represents a single Chromosome.
"""
class Chromosome:
	#*Initializes the chromosome
	def __init__(self):
		self.bits = []
		self.fitness = 0
	
	#*Finds the fitness of the chromosome using the number of disjuncts as a heuristic.
	#expression - the actual string expression
	#vars - a list of all individual variables in the expression
	#		in alphabetical order
	def evalFitness(self,expression,vars):
		bit_str = ""
		activeNot = False
		for i in range(0,len(expression)):
			x = expression[i]
			if x not in (alphabet + "!"):
				if x == "*" or i == len(expression)-1:
					if x == ")":
						bit_str += x
					result = eval(bit_str)
					if result > 0:
						self.fitness += 1
					bit_str = ""
				else:
					bit_str += x
			else:
				if x == "!":
					activeNot = True
				else:
					if activeNot:
						if self.bits[vars.index(x)] == 0:
							bit_str += "1"
						else:
							bit_str += "0"
						#print "Not_str = %s" %bit_str 
						if i == len(expression)-1:
							result = eval(bit_str)
							if result > 0:
								self.fitness += 1
						activeNot = False
					else:
						bit_str += str(self.bits[vars.index(x)])
						#print "bit_str = %s" %str(self.bits[vars.index(x)])
						if i == len(expression)-1:
							result = eval(bit_str)
							if result > 0:
								self.fitness += 1
	
	#*Creates a random assortment of bits for the chromosome
	#numVars - the number of variables in the expression
	def setBits(self,numVars):
		self.bits = [random.randint(0,1) for i in range(0,numVars)]
		"""for x in range(0,numVars):
			#self.bits.append(int(bin(random.randint(1,50))[-1:]))
			num = random.randint(0,99)
			if num % 2 == 0:
				self.bits.append(0)
			else:
				self.bits.append(1)"""
			
#----End Class


#*Perform a single crossover to generate two new children.
#*If the children are the same, a mutation is performed on one.
#*Otherwise, mutation is random.
#numVars - the number of variables in the expression
#c1, c2 - the chosen chromosomes to make offspring from
def geneticOperations(numVars,c1,c2):
	child1 = Chromosome()
	child1.bits = [b for i,b in enumerate(c1.bits)]
	child2 = Chromosome()
	child2.bits = [b for i,b in enumerate(c2.bits)]
	#Do single crossover
	cpoint = random.randint(0,numVars-2)
	portion = child1.bits[cpoint:numVars]
	portion2 = child2.bits[cpoint:numVars]
	child1.bits[cpoint:numVars] = portion2
	child2.bits[cpoint:numVars] = portion
	
	go = random.randint(0,99)
	if child1.bits == child2.bits or go % 2 == 1:
		mutate = random.randint(0,numVars-1)
		if child1.bits[mutate] == 0:
			child1.bits[mutate] = 1
		else:
			child1.bits[mutate] = 0
	return [child1,child2]
		
#*Compares the fitness of a chromosome to the number of disjuncts
#*to determine if it is a solution. If the 2 are equal, then it is
# c - a chromosome
# d - the number of disjuncts
# vars - the list of variables in the expression
def evaluateChromosomeFitness(c,d,vars):
	if c.fitness == d:
		#print "Fitness Level = %d" %c.fitness 
		for i,x in enumerate(vars):
			print "%s = %s" %(x,str(c.bits[i]))
		return True
	else:
		return False

#* Returns tuples containing the fitness ranges for the current		
#* generation.
# population - the chromosomes in the current generation
def findFitnessRanges(population):
	total = 0
	tuples = []
	min = 0
	ratio = 0
	for x in range(0,len(population)):
		total += float(population[x].fitness)
	for x in range(0,len(population)):
		if total > 0:
			ratio = int((population[x].fitness/total) * 100)
		tuples.append((min,min+ratio))	
		min = min+ratio+1
	return tuples

#* Chooses two random numbers between 0 and 100 to determine the
#* chromosomes to use in crossover
# ranges -a list of tuples representing the fitness ranges
def getRandomNumbers(ranges):
	r1 = random.randint(0,100)
	r2 = random.randint(0,100)
	index1 = 0
	index2 = -1
	for x in range(0,len(ranges)):	
		if r1 in range(ranges[x][0],ranges[x][1]):
			index1 = x
			#print "Index1: %d" %index1
		if r2 in range(ranges[x][0],ranges[x][1]):
			index2 = x
			#print "Index2: %d" %index2
		if index1 == index2:
			r2 = random.randint(0,100)
			x = 0
	return [index1,index2]
	
continue_prog = "y"

print "The following program takes an expression in conjunctive normal form"
print "and returns a combination of bits such that the expression evaluates"
print "to true."
print "+ := OR"
print "* := AND"
print "! := NOT"
print "Example: (A+B)*(!B+C+!D)*(D+!E)"

while continue_prog.lower() == "y" or continue_prog == "yes":
	expr = raw_input("Enter Expression: ")
	#Parse string and get unique variables
	disjuncts = 1		#The total number of disjuncts
	var_list = []		#A list of the vars in the expression
	for x in expr:
		#in and not in check single character strings to see if they're in 
		#the list
		if x in alphabet and x not in var_list:
			var_list.append(x)
		elif x == "*":
			disjuncts += 1
	numVars = len(var_list)
	#cross_pts = int(math.log(numVars,2))
	var_list.sort()
	#Generate initial population (create random bits for each variable)
	population = []
	popsize = int(math.log(numVars,2))
	if popsize < 2:
		popsize = 2
	if popsize % 2 != 0:
		popsize += 1
	for x in range(0,popsize):
		aChrom = Chromosome()
		aChrom.setBits(numVars)
		population.append(aChrom)
	#print "Originals: %s, %s" %(str(population[0].bits),str(population[1].bits))
	#Perform genetic algorithm until problem is solved
	solved = False
	time = 0
	while True:
		#Evaluate fitness of each member of P(t)
		for x in range(0,len(population)):
			population[x].evalFitness(expr,var_list)
			#print population[x].fitness
			if evaluateChromosomeFitness(population[x],disjuncts,var_list):
				solved = True
				break
		if solved:
			break
		#Select members of P(t) based on fitness
		#First, make ranges
		ranges = findFitnessRanges(population)		#A list of tuples for fitness ranges
		#Choose random numbers until new population has been created
		indexes = []
		newpopulation = []
		if popsize >= 2:
			list = getRandomNumbers(ranges)
			indexes.append(list[0])
			indexes.append(list[1])
			#Perform genetic operations 
			newpopulation = geneticOperations(numVars,population[indexes[0]],population[indexes[1]])
		if popsize == 4:
			list = getRandomNumbers(ranges)
			indexes.append(list[0])
			indexes.append(list[1])
			additionalpop = geneticOperations(numVars,population[indexes[2]],population[indexes[3]])
			newpopulation.append(additionalpop[0])
			newpopulation.append(additionalpop[1])
		#Replace old population with new population
		population = [x for i,x in enumerate(newpopulation)]
		time += 1
		
	continue_prog = raw_input("Go again (yes/no)? ")
			
	
	
			