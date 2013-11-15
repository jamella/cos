#Functions
def get_state_at(ks,init_state):
	"Update function, makes key-stream equations, returns ks key-stream equations"
	
	ga = 0
	gb = 0
	gc = 0
	
	#Keystream Equations
	z = ks*[0];
	
	#Guessed Gates
	GG = []
	
	#Non-Guessed Gates
	NG = []
	
	#All Gates
	AGa = []
	AGb = []
	AGc = []
	
	#Current State
	S = nv*[0];

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

		z[i] = t1+t2+t3 

		#Gates
		if((((i+1)%3)==0) and (ga_c<ga)): #Guess
			GA = 0
			GG.append(S[90]*S[91]);
			AGa.append(0);
		else: #No Guess
			GA = S[90]*S[91]
			#NG.append(S[90]*S[91]);
			AGa.append(GA);
			
			
		if((((i+1)%3)==0) and (gb_c<gb)): #Guess
			GB = 0
			GG.append(S[174]*S[175]);
			AGb.append(0);
		else: #No Guess
			GB = S[174]*S[175]
			#NG.append(S[174]*S[175]);
			AGb.append(GB);
			
		if((((i+1)%3)==0) and (gc_c<gc)): #Guess
			GC = 0
			GG.append(S[285]*S[286]);
			AGc.append(0)	
		else: #No Guess
			GC = S[285]*S[286]
			#NG.append(S[285]*S[286]);
			AGc.append(GC)

		
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
		
	return S;

def construct_ks_eq(ks,ga,gb,gc):
	"Update function, makes key-stream equations, returns ks key-stream equations"
	
	#Keystream Equations
	z = ks*[0];
	
	#Guessed Gates
	GG = []
	
	#Non-Guessed Gates
	NG = []
	
	#All Gates
	AGa = []
	AGb = []
	AGc = []
	
	#Current State
	S = nv*[0];

	#Load Initial State
	for i in range(nv):
		S[i]=s[i];
	
	#Gate counters
	ga_c=0; 
	gb_c=0; 
	gc_c=0;
	
	for i in range(ks):
		t1 = S[65] + S[92]
		t2 = S[161] + S[176]
		t3 = S[242] + S[287]

		z[i] = t1+t2+t3

		#Gates
		if((((i+1)%3)==0) and (ga_c<ga)): #Guess
			GA = 0
			GG.append(S[90]*S[91]);
			AGa.append(0);
		else: #No Guess
			GA = S[90]*S[91]
			#NG.append(S[90]*S[91]);
			AGa.append(GA);
			
			
		if((((i+1)%3)==0) and (gb_c<gb)): #Guess
			GB = 0
			GG.append(S[174]*S[175]);
			AGb.append(0);
		else: #No Guess
			GB = S[174]*S[175]
			#NG.append(S[174]*S[175]);
			AGb.append(GB);
			
		if((((i+1)%3)==0) and (gc_c<gc)): #Guess
			GC = 0
			GG.append(S[285]*S[286]);
			AGc.append(0)	
		else: #No Guess
			GC = S[285]*S[286]
			#NG.append(S[285]*S[286]);
			AGc.append(GC)

		
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
		
	return [z,GG,NG,AGa,AGb,AGc];

def iterative_variable_subs(subs_nums,z):
	
	z_new = list(z)

	for i,v in enumerate(z):
		z_new[i] = substitute_variables(QR,subs_nums,v)
		
	return z_new

def set_vars_one(L):
	var_vec = 288*[0];
	for i in range(288):
		var_vec[i]=s[i];

	for i in range(len(L)):
		var_vec[L[i]]=1+s[0]+s[0];

	return var_vec
	
def set_vars_zero(L):
	var_vec = 288*[0];
	for i in range(288):
		var_vec[i]=s[i];

	for i in range(len(L)):
		var_vec[L[i]]=0+s[0]+s[0];

	return var_vec
	
def set_vars_random(L):
	var_vec = 288*[0];
	for i in range(288):
		var_vec[i]=s[i];

	for i in range(len(L)):
		var_vec[L[i]]=int(0.5<random.random())+s[0]+s[0];

	return var_vec

def substitute_one_in_ks_eq(L,subs_vars):
	
	L_new = len(L)*[0];
	
	for i in range(len(L)):
		L_new[i] = L[i](set_vars_one(subs_vars));
		
		print "HERE"
	
	return L_new;

#Todo - (Deprecated, need to check through code and stop using)
def obtain_lin_eq_in_T(z,T):
	new_z = [];

	for eq in z:
		bad = false
		itype = sage.rings.finite_rings.integer_mod.IntegerMod_int
		if(not(type(eq)==itype)):
			for j in eq.monomials(): #Only works with linears
				if(j not in T):
					bad = true;
					break

		if(not bad):
			new_z.append(eq);

	return new_z
	
def obtain_eqs_of_degree_in_T_old(z,deg,T): #Deprecated
	new_z = [];

	for eq in z:
		eqq = eq+s[0]+s[0]
		bad=False
		if((eqq).degree()==deg):
			for j in (eq+s[0]+s[0]).variables():
				if((j not in T) and (j!=(s[0]+s[0]+1))):
					bad=True
		else:
			bad=True
		
		if(not bad):
			new_z.append(eq);

	return new_z
	
def obtain_eqs_of_degree_in_T(z,deg,T): #Would like to test again
	new_z = [];

	Tall = [s[i] for i in range(288)]
	Tnot = set(Tall)-set(T)

	for eq in z:
		if(QR(eq).degree()==deg):
			if(eq_contains_no_T(eq,Tnot)):
					new_z.append(eq);

	return new_z

def count_lin_eq(z):
	count = 0

	for i in range(len(z)):
		if(((s[0]+s[0]+z[i]).degree()==1)):
			count+=1;
	return count;

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
		
	return [LS,Gsums];
	
				
def make_diff_eqs_raw(z,sub_vars_num,limit):
	#print "\nMaking raw difference equations from difference-set:\n", sub_vars_num
	
	#First 22 among 66 are already linear
	zslice = z[66:]
	zprime = z[66:];
	diffs = len(zslice)*[0];
	
	sub_vars_var = 288*[0]
	
	for i in range(288):
		if(i in sub_vars_num):
			sub_vars_var[i] = s[i]+1
		else:
			sub_vars_var[i] = s[i]
			
	temp = 100;
	
	#Substitute vars in subvars with var+1
	for i in range(0,limit):#for i in range(len(zprime)):
		
		zprime[i] = substitute_variables(QR,sub_vars_var,zprime[i]); #WOW fast! (PolyBoRi function)
		#for sub_var in sub_vars:
		#	zprime[i] = zprime[i].subs({s[sub_var]:s[sub_var]+1}) #Much slower... (Generic Multivar Substitution)
		
		#Make difference equations
		diffs[i] = zslice[i]+zprime[i];
			
	#[Progress in pct.				
	#	if(floor(100*i/len(zprime))%1==0):
	#		sys.stdout.write("\b" * 7)
	#		sys.stdout.write("%d pct" % (ceil(100*i/len(zprime))));
	#		sys.stdout.flush()
	#sys.stdout.write("\b" * 7)
	#sys.stdout.write("Done making raw difference equations.\n")	
	#Progress in pct.]	
	
	return diffs;


def strip_zeros_ones(diffs):
	
	diffs_raw_eqs = [];
	zprime_nums = [];
	
	for eq in range(len(diffs)):
		if(not((diffs[eq]==0) or (diffs[eq]==1))):
			diffs_raw_eqs.append(diffs[eq]);
			zprime_nums.append(eq+66);
			
	
	#print "Done stripping."
	return [diffs_raw_eqs,zprime_nums]

def eq_contains_only_T_old(eq,T): #Deprecated

	#T is of the form [s[x],s[y]...]
	eq_only_T = True

	I = eq.variables()

	for i in I:
		if(not(i in T)):
			eq_only_T = False
			break
	
	return eq_only_T 
	
	
def eq_contains_no_T(eq,T): #Would like to test more

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
	#print "Done stripping."
	return [diffeqsT,new_z_nums];

def uniquify_with_z_nums(diffs,z_nums):
	new_z_nums = []
	new_diffs = []
	
	for eq in range(len(diffs)):
		if(not diffs[eq] in new_diffs):
			new_diffs.append(diffs[eq])
			new_z_nums.append(z_nums[eq])
	
	return [new_diffs,new_z_nums]

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
	
	
	return [unique_in_T,zp_nums_uniqueT];
	
def get_lin_diff_eqs(diff_eqs,zprimes):
	
	lin_diffs = [];
	zprimes_new = [];
	
	for eq in range(len(diff_eqs)):
		if(diff_eqs[eq].degree()==1):
			lin_diffs.append(diff_eqs[eq])
			zprimes_new.append(zprimes[eq])
			
	return [lin_diffs,zprimes_new];

def sample_no_replace(set,size):
	set = list(set)
	random.shuffle(set)
	
	return set[:size]	
	
def lin_eq_to_vec(eq):
	
	vec = vector(GF(2),nv*[0]);
	
	for j in eq.monomials():
		for i in range(nv):
			if(j==s[i]):
				vec[i]=1;
	
	return vec
	
def eq_list_to_matrix(L):
	
	Tsize = len(L);
	
	M = matrix(GF(2),Tsize,nv);
	
	for i in range(len(L)):
		M[i] = lin_eq_to_vec(L[i]);
		
	return M

def add_vecs_in_rows(M,vecs,r_nums):
	c = 0;
	for i in rnums:
		M[i] = vecs[0];
		c+=1;
		
	return M
