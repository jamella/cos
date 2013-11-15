#Self-contained Implementation of Maximov/Biryukov Attack
#Code for playing around with the attack parameters, and to show how it works.
#It also shows that the rank of the equation system in Phase 2 is not expected to be 192

#Initialization, Clear screen and variables, get BooleanPolynomialRing etc.
reset();
os.system("clear");

print("Variables have been reset!");
print("Setting parameters...");

import time
import sys
import random
from polybori import substitute_variables
QR = BooleanPolynomialRing(288,names='s',order='lex')
s = QR.gens()
nv = 288


#Functions
def get_guessed_ks_at(ks,init_state,ga=0,gb=0,gc=0):
	"Update function, makes key-stream equations, returns ks key-stream equations"
	"i.e. for ks ticks. Default is to return keystream equations without any part"
	"''guessed''. One can set ga,gb,gc as in Maximov/Biryukov attack, to guess "
	"gates as explained in the article of the attack"
	
	#Initialize Keystream Equations
	z = ks*[0];
	
	#Current State
	S = nv*[0];

	#Guessed we don't guess (for using in summed gates guessing)
	AGa = []
	AGb = []
	AGc = []

	#Load Initial State
	for i in range(nv):
		S[i]=init_state[i];
	
	#Gate counters
	ga_c=0; 
	gb_c=0; 
	gc_c=0;
	
	for i in range(ks):
		t1 = S[65] + S[92]
		t2 = S[161] + S[176]
		t3 = S[242] + S[287]

		z[i] = t1+t2+t3 #i'th keystream equation

		#Gates
		if((((i+1)%3)==0) and (ga_c<ga)): #Guess
			GA = 0
			AGa.append(0);

		else: #No Guess
			GA = S[90]*S[91]
			AGa.append(GA);
			
			
			
		if((((i+1)%3)==0) and (gb_c<gb)): #Guess
			GB = 0
			AGb.append(0);
			
		else: #No Guess
			GB = S[174]*S[175]
			AGb.append(GB);
			
		if((((i+1)%3)==0) and (gc_c<gc)): #Guess
			GC = 0
			AGc.append(0);
			
		else: #No Guess
			GC = S[285]*S[286]
			AGc.append(GC);

		
		#Updates
		t1 = t1 + GA + S[170]
		t2 = t2 + GB + S[263]
		t3 = t3 + GC + S[68]

		for j in range(287,177,-1):
			S[j] = S[j-1]
		S[177]=t2;

		for j in range(176,93,-1):
			S[j] = S[j-1]
		S[93]=t1;

		for j in range(92,0,-1):
			S[j] = S[j-1]
		S[0]=t3;
		
		#Gate increments
		if(((i+1)%3)==0): 
			ga_c+=1;
			gb_c+=1;
			gc_c+=1;
		
	return z,AGa,AGb,AGc;

def gen_sum_equations(z,AGa,AGb,AGc):
	
	sum_eqs = 15;
	LS = [0]*sum_eqs;
	Gsums = []
	
	for i in range(15):
		idx = 179+i*3;
		LS[i] = z[idx];
		
	for i in range(0,5):
		guess = QR.ideal(AGb[113+3*i])
		LS[i]=LS[i].reduce(guess);
		Gsums.append(guess);
		
	for i in range(5,10):
		guess = QR.ideal(AGb[113+3*i]+AGc[113+3*i])
		LS[i] = LS[i].reduce(guess);
		Gsums.append(guess);
		
	for i in range(10,14):
		guess = QR.ideal(AGb[113+3*i]+AGc[113+3*i]+AGa[113+3*(i-1)])
		LS[i] = LS[i].reduce(guess);
		Gsums.append(guess);

	for i in range(14,15):
		guess = QR.ideal(AGb[113+3*i]+AGc[113+3*i]+AGa[113+3*(i-1)]+AGc[113+3*(i-9)])
		LS[i] = LS[i].reduce(guess);
		Gsums.append(guess);
		
	return LS;

#Test if no eqs. have vars. in T	
def eq_contains_no_T(eq,T): 

	#T is of the form [s[x],s[y]...]
	eq_only_T = False

	I = set(eq.variables())
	T = set(T)

	if(len(T.intersection(I))==0):
		eq_only_T = True
	
	return eq_only_T 

#Obtain equations in list z that are all vars. in the set T and of a degree deg.
def obtain_eqs_of_degree_in_T(z,deg,T):
	new_z = [];

	Tall = [s[i] for i in range(288)]
	Tnot = set(Tall)-set(T)

	for eq in z:
		if(QR(eq).degree()==deg):
			if(eq_contains_no_T(eq,Tnot)):
					new_z.append(eq);

	return new_z
	
#Iteratively substitute
def iterative_variable_subs(subs_arr,z):
	
	z_new = list(z)

	for i,v in enumerate(z):
		z_new[i] = substitute_variables(QR,subs_arr,v)
		
	return z_new

#--------------------------------------
#Main
#--------------------------------------


#Maximov/Biryukov Attack Phase 1 Equations
ga = 46
gb = 37
gc = 42

ks = 288

init_state = [s[i] for i in range(nv)]
T0 = [s[i] for i in range(0,288,3)]
T1 = [s[i] for i in range(1,288,3)]
T2 = [s[i] for i in range(2,288,3)]

#Guess gates zero
z,AGa,AGb,AGc = get_guessed_ks_at(ks,init_state,ga,gb,gc)
z_lin = obtain_eqs_of_degree_in_T(z,1,T0) #Linear Equations in T0


S = Sequence(z_lin,QR)
M,v = S.coefficient_matrix()
print M.rank() #Rank is 59

#Guess sum of gates zero
z_sums = gen_sum_equations(z,AGa,AGb,AGc)
S = Sequence(z_lin+z_sums,QR)
M,v = S.coefficient_matrix()
print M.rank() #Rank is now 74


#After this the remaining 22 variables of T0 are guessed/fixed



#Phase 2
trials = 100
r_mean = 0

for trial in range(trials):
	z,AGa,AGb,AGc = get_guessed_ks_at(ks,init_state,ga,gb,gc) #Initialize z w. guesses
	
	#Randomly fix/guess T0 Vars
	subs_arr = list(init_state)
	for i in range(0,nv,3):
		if(random.random()>0.5):
			subs_arr[i] = QR(1)
		else:
			subs_arr[i] = QR(0)

	z = iterative_variable_subs(subs_arr,z)
	T12 = T1+T2
	z_lin = obtain_eqs_of_degree_in_T(z,1,T12) #Linear Equations in T1+T2

	S = Sequence(z_lin,QR)
	M,v = S.coefficient_matrix()
	
	r_mean += M.rank()
	

print "Final mean rank:", float(r_mean/trials) #Rank is on average 191.1, not 192



