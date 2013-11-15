#Self-Contained Instructive DFA Code
#Showing how we studied difference equations for Trivium

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

def eq_contains_no_T(eq,T):

	#T is of the form [s[x],s[y]...]
	eq_only_T = False

	I = set(eq.variables())
	T = set(T)

	if(len(T.intersection(I))==0):
		eq_only_T = True
	
	return eq_only_T 

def strip_eqs_not_in_T(diff_eqs,z_nums,T):
	
	#Easier to check existence in eq_contains_no_T
	#so therefore we want to exclude existence of what we don't want
	Tall = [s[i] for i in range(0,288)]
	Tnot = set(Tall)-set(T)
	
	diffeqsT = [];
	new_z_nums = [];
	
	for eq in range(len(diff_eqs)):
		if(eq_contains_no_T(diff_eqs[eq],Tnot)):
			diffeqsT.append(diff_eqs[eq]);
			new_z_nums.append(z_nums[eq]);

	return [diffeqsT,new_z_nums];

def strip_zeros_ones(diffs):
	diffs_raw_eqs = [];
	zprime_nums = [];
	
	for eq in range(len(diffs)):
		if(not((diffs[eq]==0) or (diffs[eq]==1))):
			diffs_raw_eqs.append(diffs[eq]);
			zprime_nums.append(eq+66);
			
	return [diffs_raw_eqs,zprime_nums]

def make_diff_eqs_raw(z,sub_vars_num,limit):
	
	#First 22 among 66 are already linear
	zslice = list(z[66:limit+66])
	zprime = list(z[66:limit+66])
	diffs = len(zslice)*[0];
	

	sub_vars_var = 288*[0]
	
	for i in range(288):
		if(i in sub_vars_num):
			sub_vars_var[i] = s[i]+1
		else:
			sub_vars_var[i] = s[i]

	#Substitute vars in subvars with var+1
	for i in range(0,limit):#for i in range(len(zprime)):
		
		zprime[i] = substitute_variables(QR,sub_vars_var,zprime[i]); #WOW fast! (PolyBoRi function)
		#for sub_var in sub_vars:
		#	zprime[i] = zprime[i].subs({s[sub_var]:s[sub_var]+1}) #Much slower... (Generic Multivar Substitution)
	
		#Make difference equations
		
		diffs[i] = zslice[i]+zprime[i];
	
	
	return diffs;


def get_unique_diff_eqs_in_T(z,sub_vars,T,limit):
	
	#Make equations and sort out zeros and ones
	diffs_raw = make_diff_eqs_raw(z,sub_vars,limit)
	
	
	#Strip zeros and ones
	[diffs_raw_eqs,zprime_nums]= strip_zeros_ones(diffs_raw)
	
	#Uniquify
	diffs_unique=diffs_raw_eqs
	zprime_nums_unique = zprime_nums
	
	
	#Obtain equations only in T
	[unique_in_T,zp_nums_uniqueT] = strip_eqs_not_in_T(diffs_unique,zprime_nums_unique,T)

	
	return diffs_unique,zp_nums_uniqueT;

#--------------------------------------
#Main
#--------------------------------------

#Initialize normal equations for Trivium keystream
ks = 288

init_state = [s[i] for i in range(nv)]
T0 = [s[i] for i in range(0,288,3)]
T1 = [s[i] for i in range(1,288,3)]
T2 = [s[i] for i in range(2,288,3)]
T_all = T1+T2+T0


z,dummy1,dummy2,dummy3 = get_guessed_ks_at(ks,init_state)


#Number of diff. eqs. past no. 66 to study (below 66, all constant)
limit = 10

#Inject differeces/faults positions and get difference equations
sub_vars = [174,175]
diff_eqs,z_indices = get_unique_diff_eqs_in_T(z,sub_vars,T_all,limit)

#In this case we get: 
#diff_eqs = [s174 + s175 + 1, s173 + 1]
#z_indices = [66,67]

#So:
#z'_66 = s174 + s175 + 1
#z'_67 = s173+1

