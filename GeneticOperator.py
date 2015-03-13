import random
import string
import math

alphabet = string.letters

class Chromosome:
	def __init__(self):
		self.bits = []
		self.fitness = 0
		
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
						activeNot = False
					else:
						bit_str += str(self.bits[vars.index(x)])
						print "bit_str = %s" %str(self.bits[vars.index(x)])
						if i == len(expression)-1:
							result = eval(bit_str)
							if result > 0:
								self.fitness += 1
						
	def setBits(self,numVars):
		for x in range(0,numVars):
			self.bits.append(random.randint(0,1))

	def mutate(self):
		index = random.randint(0,len(self.bits)-1)
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
	child1 = c1
	child2 = c2
	child1.fitness = 0
	child2.fitness = 0
	while max <= numVars:
		part1 = c1.bits[min:max]
		part2 = c2.bits[min:max]
		child1.bits[min:max] = part2
		child2.bits[min:max] = part1
		min = max+1
		if min >= max:
			break
		max = random.randint(min,numVars)
		
	mutate = random.randint(0,1)
	if mutate == 1:
		child1.mutate()
	mutate = random.randint(0,1)
	if mutate == 1:
		child2.mutate()
	return [child1,child2]
		
def evaluateChromosomeFitness(c,d,vars):
	if c.fitness == d:
		print "Fitness Level = %d" %c.fitness 
		print "%s = %s" %(str(vars).strip("[]"),str(c.bits).strip("[]"))
		return True
	else:
		return False

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
	#print "Disjuncts = %d" %disjuncts
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
	print "Originals: %s, %s" %(str(population[0].bits),str(population[1].bits))
	#Perform genetic algorithm until problem is solved
	solved = False
	time = 0
	while True:
		#Evaluate fitness of each member of P(t)
		for x in range(0,len(population)):
			population[x].evalFitness(expr,var_list)
			print population[x].fitness
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
		population = newpopulation
		time += 1
		print "time = %d" %time
		for x in range(0,len(population)):
			print population[x].bits
		
	continue_prog = raw_input("Go again (yes/no)? ")
			
	
	
			