def do_equation_construction(ga=46,gb=37,gc=42,with_g_sums=True):
	#No. keystream equations
	ks = 288;
	G = ga+gb+gc;
	H = 0;

	#print "\nPhase 1:"
	[z_no_guess,dummy1,dummy2,dummy3,dummy4,dummy5] = construct_ks_eq(ks,0,0,0);
	#print "Constructed Equations (no guesses)."
	[z,GG,NG,AGa,AGb,AGc] = construct_ks_eq(ks,ga,gb,gc);
	#print "Constructed Equations (with guesses)."

	#Obtain lin eq. in T0 from initial guesses
	T0nums = range(0,288,3);
	T0 = [s[i] for i in T0nums];
	zT0 = obtain_lin_eq_in_T(z,T0);
	dprime = count_lin_eq(zT0);
	

	if(with_g_sums):
		#Obtain equations from AND-gate sum guesses
		[zT0sums,GuessedSums] = gen_sum_equations(z,AGa,AGb,AGc)
		dsums = count_lin_eq(zT0sums);
		print "lin_eq(T0) from guessed gatesums: ", dsums
	else:
		zT0sums = None
		GuessedSums = None
		dsums = 0

	#"Guess" 22 variables and Proceed to Phase 2
	zP2 = iterative_variable_subs(set_vars_one(T0nums),z)
	dphase2 = count_lin_eq(zP2)
	
	ph1guess = 96-(dprime+dsums)
	
	
	if(with_g_sums):
		log_complexity_of_sums = 9.7
		print "Complexity of guessing sums: 2^" + str(log_complexity_of_sums)
	else:
		log_complexity_of_sums = 0
	
	
	ph2guess = 192-dphase2
	
	#Can print if wanted
	if(with_g_sums):
		print "\nScenario: "
		print " (ga,gb,gc) = ("+  str(ga)  + "," +  str(gb) + "," +  str(gc) + ")"
		print " (G,H) = (" + str(G) + "," + str(H) + ")"
		print
		print "lin_eq(T0) from guessed gates: ", dprime
		print "\nPhase 2:"
		print "Assuming knowledge of guessed gates and missing variables from Phase 1\n(i.e. all 96 vars in T0 are known)."
		print "lin_eq(T1 U T2): ", dphase2
		print "Attack Complexity:"
		print "Gained eqs. in Ph. 1: " + str(dprime+dsums)
		print "Needed to guess: " + str(ph1guess)
		print "Keystream/Time: 2^" + str(round(float(log((0.75^-(ga+gb+gc)),2)),1))
		print "Guesses needed in Ph. 2: " + str(ph2guess)
		print "Complexity: 2^" + str(round(float(log((0.75^-(ga+gb+gc)),2))+ph1guess+ph2guess+log_complexity_of_sums,1))
	

	return [z_no_guess,z,zT0,dprime,zT0sums,dsums,zP2,dphase2,GuessedSums]
