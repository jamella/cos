import copy

class EquationSystem:
	"A class which can hold all equations pertaining to a specific set of variables,\
	more specifically in this case: variables in T0, T1 and T2"
	
	def __init__(self,linears=[],quadratics=[],all_equations=[],booleanring=QR):
		self.all_equations = all_equations
		self.booleanring = booleanring #The specific boolean ring that we are working in
		self.linears = [i+i.has_constant_part() for i in linears] #Meant to be a list of linear equations
		self.linear_seq = Sequence(self.linears,self.booleanring)
		self.quadratics = quadratics #Meant to be a list of quadratic equations
		self.quad_seq = Sequence(self.quadratics,self.booleanring)
		
	def rank_of_linears(self):
		M,v = self.linear_seq.coefficient_matrix()

		return rank(M)
	
	def linear_var_count(self):	
		return len(self.linear_seq.variables())
		
	def quad_var_count(self):	
		return len(self.quad_seq.variables())
			
	def get_lin_count(self):
		return len(self.linear_seq)
	
	def get_quad_count(self):
		return len(self.quad_seq)
		
	def free_variable_count(self):
		return self.linear_var_count()-self.rank_of_linears()
		
	def add_linear_equations(self,list_of_eqs):
		for eq in list_of_eqs:
			self.linears.append(eq)
		
		self.linears = [i+i.has_constant_part() for i in self.linears] #Meant to be a list of linear equations
		self.linear_seq = Sequence(self.linears,self.booleanring)
		
	def add_quadratic_equations(self,list_of_eqs):
		for eq in list_of_eqs:
			self.quadratics.append(eq)
		
		self.quad_seq = Sequence(self.quadratics,self.booleanring)
	
	def get_coeff_matrix(self):
		M,v = self.linear_seq.coefficient_matrix()
		
		return [M,v]
	
	#Given a list of known variables/guessed variables, these are set to one (note: think about end experiment, should be set random and test many or?)
	def guess_vars(self,L): #Input list of vars to guess
		self.linears = iterative_variable_subs(set_vars_one(L),self.linears)
		self.quadratics = iterative_variable_subs(set_vars_one(L),self.quadratics)
		self.all_equations = iterative_variable_subs(set_vars_one(L),self.all_equations)
	
	#Gets vars that are immediately revealed by the differential equations, e.g. z_i = s[j]+1
	def get_revealed_var_idx(self): #In all_equations list
		return [[self.all_equations[i].monomials()[0].index() for i in range(len(self.all_equations)) if self.all_equations[i].nvariables()==1]]
		#Completely incomprehensible at first glance, maybe change this for understandability
			
	def merge(self,other):
		self.add_linear_equations(other.linears)
		self.add_quadratic_equations(other.quadratics)
		


def printComplexity(Ph1,Ph2,G=[46,37,42]):
	"For printing complexities of attack"
	
	[dummy1,dummy2,dummy3,dprime,dummy4,dummy5,dummy6,dphase2,dummy7] = do_equation_construction(G[0],G[1],G[2])
		
	Theta1 = dprime-22
	Theta2 = dphase2
			
			
	
	print "Phase 1:"
	print "(ga,gb,gc): (" + str(G[0]) + "," + str(G[1]) +  "," + str(G[2]) + ")"
	print "Keystream: 2^" + str(round(float(log((0.75^-(G[0]+G[1]+G[2])),2)),1))
	print "#Linear Equations: " + str(Ph1.get_lin_count())
	print "Theta1 (added by MB): " + str(Theta1)
	print "#Linear Variables: " + str(len(Ph1.linear_seq.variables()))
	print "#Quadratic Equations: " + str(Ph1.get_quad_count())
	print "Rank of system: " + str(Ph1.rank_of_linears())
	print "#Free Variables: " + str(Ph1.free_variable_count())
	print "Resulting Complexity: 2^" + str(round(float(log((0.75^-(G[0]+G[1]+G[2])),2)),1)+Ph1.free_variable_count()) + "\n"
	print "Phase 2:"
	print "#Free Variables: " + str(Ph2.free_variable_count())
	print "#Linear Variables: " + str(len(Ph2.quad_seq.variables()))
	print "#Linear Equations: " + str(Ph2.get_lin_count())
	print "Theta2 (added by MB): " + str(Theta2)
	print "#Quadratic Equations: " + str(Ph2.get_quad_count())
	
	print "Final Complexity: c*2^" + str(round(float(log((0.75^-(G[0]+G[1]+G[2])),2)),1)+Ph1.free_variable_count()+Ph2.free_variable_count())

#Static DFA no revealed
def constructPhases(ga=46,gb=37,gc=42):
	"Construct Phase 1 and 2 for Maximov/Biryukov attack. Each Phase is returned as\
	a separate equation system. Guessed gate sums is not implemented here"
	
	#No. keystream equations
	ks = 288;
	G = ga+gb+gc;
	H = 0;
	
	#KS-eqs with guesses
	[z,GG,NG,AGa,AGb,AGc] = construct_ks_eq(ks,ga,gb,gc,false);

	#Obtain lin eq. in T0 from initial guesses
	T0nums = range(0,288,3);
	T0 = [s[i] for i in T0nums];
	T_all = [s[i] for i in range(0,288)];
	
	zP1lin = obtain_eqs_of_degree_in_T(z,1,T0) #Linear equations in T0 only from guesses 
	zP1quad = obtain_eqs_of_degree_in_T(z,2,T0) #Quadratic equations in T0 only from guesses

	#Equation System for Phase 1
	Ph1 = EquationSystem(zP1lin,zP1quad,QR)

	#"Guess" remaining variables and Proceed to Phase 2
	zP2 = iterative_variable_subs(set_vars_zero(T0nums),z)
	zP2lin = obtain_eqs_of_degree_in_T(zP2,1,T_all)
	zP2quad = obtain_eqs_of_degree_in_T(zP2,2,T_all) #TODO
	
	#Equation System for Phase 2
	Ph2 = EquationSystem(linears = zP2lin,quadratics = zP2quad)

	return [Ph1,Ph2]

#Static DFA no revealed
def injectFault(z_no_guess,fault_positions):
	
	limit = 288-66
	T_all = [s[x] for x in range(0,288)]
	
	[diff_eqs,zprimes] = get_unique_diff_eqs_in_T(z_no_guess,fault_positions,T_all,limit)			
	
	
	lin_diff = obtain_eqs_of_degree_in_T(diff_eqs,1,T_all)
	quad_diff = obtain_eqs_of_degree_in_T(diff_eqs,2,T_all)
	
	diff_eqs = EquationSystem(linears = lin_diff,quadratics = quad_diff)
	
	return [diff_eqs]

#Static DFA no revealed
def combineEqSystems(ph1,ph2,diff_eqs):
	
	T0nums = range(0,288,3)
	T0 = [s[i] for i in range(0,288,3)]
	T0linears = obtain_eqs_of_degree_in_T(diff_eqs.linears,1,T0)
	T0quadratics = obtain_eqs_of_degree_in_T(diff_eqs.quadratics,2,T0)
	
	ph1.add_linear_equations(T0linears)
	ph1.add_quadratic_equations(T0quadratics)
	
	ph2_diff_linears = iterative_variable_subs(set_vars_zero(T0nums),diff_eqs.linears)
	ph2_diff_quadratics = iterative_variable_subs(set_vars_zero(T0nums),diff_eqs.quadratics)
	
	ph2.add_linear_equations(ph2_diff_linears)
	ph2.add_quadratic_equations(ph2_diff_quadratics)
	
	return [ph1,ph2]
	
#Static DFA with revealed
def injectFaultListOut(z_no_guess,fault_positions,limit):
	
	#limit = 288-66
	T_all = [s[x] for x in range(0,288)]
	
	[diff_eqs,zprimes] = get_unique_diff_eqs_in_T(z_no_guess,fault_positions,T_all,limit)			
	
	return [diff_eqs]

#Static DFA with revealed	
def processEquations(all_eqs):
	de_system = EquationSystem(all_equations=all_eqs)
	
	this_round_revealed = [1000]
	revealed_idxs = []
	
	Tall = [s[i] for i in range(288)]
	
	
	while len(this_round_revealed)!=0:
		[this_round_revealed] = de_system.get_revealed_var_idx()
		revealed_idxs += this_round_revealed
		de_system.guess_vars(this_round_revealed)
		
		#Gauss-Jordan 
		temp_lin = obtain_eqs_of_degree_in_T(de_system.all_equations,1,Tall)
		M,v = Sequence(temp_lin,QR).coefficient_matrix()
		M.echelonize()
		GJeqs = M*v
		GJlist = [(GJeqs)[i][0] for i in range(M.nrows())]
		GJ = EquationSystem(all_equations = GJlist)
		#pdb.set_trace()
		[this_round_revealed] = GJ.get_revealed_var_idx()
		revealed_idxs += this_round_revealed
		de_system.guess_vars(this_round_revealed)
		
		
	return [de_system.all_equations,revealed_idxs]
	
#Static DFA with revealed
def mbAttackConstruction(G,ks):

	ga = G[0]; gb = G[1]; gc = G[2] 	
	
	[z,GG,NG,AGa,AGb,AGc] = construct_ks_eq(ks,ga,gb,gc)
	
	return [z]
