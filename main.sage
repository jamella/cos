#Main tester
load clear.sage
load polybori_initialization.sage
load polybori_functions.sage
load polybori_equation_constructer.sage
load equation_lib.sage
load experiment_lib.sage

print "------------------------------------------------------------"

from itertools import product


#Attack Complexity Estimation Used in Thesis
def run_attack_estimation(isd_weight,l_length):
	
	ks = l_length
	limit = ks-66
	trials = 10
	
	[z_no_guess,dummy1,dummy2,dummy3,dummy4,dummy5] = construct_ks_eq(ks,0,0,0);

	sum_revealed_num_0 = 0
	sum_revealed_num_1 = 0
	
	T0num = range(0,288,3)
	T0 = [s[i] for i in T0num]
	T1num = range(1,288,3)
	T2num = range(2,288,3)
	T12num = T1num+T2num
	T12 = [s[i] for i in T12num]
	Tall = [s[i] for i in range(288)]
	
	ga = -1
	gb = 0
	gc = 0

	outer = 1
	tests = 1*outer
	stats = ExperimentStatistics(trials,tests)

	for i in range(outer):
		print i 
		for j in range(1):
			
			#Construct Maximov/Biryukov Attack Equations
			
			ga+=1
			gb+=1
			gc+=1
				
			G = [ga,gb,gc]
					
			
			
			[dummy1,mb,zT0,dummy3,dummy4,dummy5,zP2,dphase2,dummy7] = do_equation_construction(ga,gb,gc,false)
			
			
			#All lin. eqs. phase 1 mb
			tempM1,tempv = Sequence(zT0,QR).coefficient_matrix()
			
			
			#All lin eqs. phase 2 given phase 1 mb, eqs. then ph1 has revealed T0 vars
			tempM2,tempv = Sequence(obtain_eqs_of_degree_in_T(zP2,1,Tall),QR).coefficient_matrix()
			
			
			theta1 = rank(tempM1)-22; #Added in phase 1 to 22 in rank
			theta2 = rank(tempM2)-44 #Added in phase 2 to 44 in rank


			rhohat1 = []
			rhohat2 = []
			complexities = []
			
			
			for k in range(trials):
				#Inject a "fault"-vector in original keystream equations and obtain differential equations
				#fault_positions = [x for x in range(288) if random.random()>0.5]
				fault_positions = sample_no_replace(range(288),isd_weight)
				[de] = injectFaultListOut(z_no_guess,fault_positions,limit)
			
				#Process all equations, mb is equations with guesses ph1, mb includes the first 66 eqs.
				all_eqs = mb+de+list(z_no_guess[66:])
				ae_proc,revealed_vars_idx = processEquations(all_eqs)
				revealed_vars = [s[x] for x in revealed_vars_idx]
				

				revealed_varsT0 = []
				revealed_varsT12 = []
				for y in revealed_vars:
					if(y in T0):
						revealed_varsT0+= [y]
					elif(y in T12):
						revealed_varsT12 += [y]
						
				ph1lin = obtain_eqs_of_degree_in_T(ae_proc,1,T0)
				ph1quad = obtain_eqs_of_degree_in_T(ae_proc,2,T0)
				ph1 = EquationSystem(linears=ph1lin,quadratics=ph1quad)
			
				
				sum_revealed_num_0+=len(revealed_varsT0)
				sum_revealed_num_1+=len(revealed_varsT12)
				
				#Calc. Contribution of Differential/Injected fault
				all1 = ph1lin+revealed_varsT0
				tempM1,tempv =Sequence([x+x.has_constant_part() for x in all1],QR).coefficient_matrix()
				
				
				#Counts in revealed vars and contribution of differential
				rhohat1_var = rank(tempM1)-(theta1+22)
				rhohat1 += [rank(tempM1)-(theta1+22)]
				
			
				temp_es = EquationSystem(all_equations = ae_proc)
				temp_es.guess_vars(T0num)
				
				ph2lin = obtain_eqs_of_degree_in_T(temp_es.all_equations,1,Tall)
				ph2quad = obtain_eqs_of_degree_in_T(temp_es.all_equations,2,Tall)
				ph2 = EquationSystem(linears = ph2lin,quadratics = ph2quad)
				
				#Calc. Contribution of Differential
				
				all2 = ph2lin+revealed_varsT12
				tempM2,tempv = Sequence([x+x.has_constant_part() for x in all2],QR).coefficient_matrix()
	
				rhohat2_var = rank(tempM2)-(theta2+44)
				rhohat2 += [rank(tempM2)-(theta2+44)]
				
				
				complexities += [96-(theta1+22+rhohat1_var)+192-(theta2+44+rhohat2_var)+1]	
					
			stats.update([ga,gb,gc],[theta1],[theta2],rhohat1,rhohat2,complexities)


	fname = "./trials" + str(trials) + "l" + str(l_length) + "w" + str(isd_weight) + ".txt"
	stats.latex_stats(fname)
	fid = open(fname,"a")
	fid.write("(c1,c2) = " + str(float(sum_revealed_num_0/(trials*tests))) + " , " + str(float(sum_revealed_num_1/(trials*tests)))+ ")")
