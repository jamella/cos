class ExperimentStatistics:

	#Trials being samples pr. test. tests being the number of different g-sets to try
	def __init__(self,trials,tests): 
		self.gs = []
		self.theta1 = []
		self.theta2 = []
		self.rhohat1 = []
		self.rhohat2 = []
		self.complexities = []
		self.trials = trials
		self.tests = tests
	
	#gs, rhohats, complexities are lists, thetas are numbers
	#To update each time "trials" trials have been done
	def update(self,gs,theta1,theta2,rhohat1,rhohat2,complexities):
		self.gs+=[gs]
		self.theta1+=theta1
		self.theta2+=theta2
		self.rhohat1+=[rhohat1]
		self.rhohat2+=[rhohat2]
		self.complexities+=[complexities]
	
	def meanCalc(self,L): #Mean 
		return float(sum(L))/self.trials
		
	def stdCalc(self,L,mu): #Standard Deviation
		
		if(self.trials==1): #Avoid division by zero with only one trial
			return 0
		else:
			return sqrt((float(1/(self.trials-1)))*sum([(L[j]-mu)^2 for j in range(self.trials)]))
	
	def latex_stats(self,filename): #Latex formatting table
		f = open(filename,"w")
		
		f.write("\\begin{center}\n")
		f.write("\\begin{tabular}{l l l l l l l l l l l}\n")
		f.write("\\toprule\n")
		f.write("$(g_a,g_b,g_c)$ & \\log_2(\\mathcal{D}) &  $\\theta_1$ & $\\theta_2$ $\\mu(\\hat{\\rho}_1)$ & $\\sigma(\\hat{\\rho}_1)$ & $\\mu(\\hat{\\rho}_2)$ & $\\sigma(\\hat{\\rho}_2)$ & $\\mu(C)$ & $\\sigma(C)$ & $\\mathcal{T}_{Der}$\\\\\\midrule\n")
		for i in range(self.tests):
			G = "(" + str(self.gs[i][0]) + "," + str(self.gs[i][1])+ "," + str(self.gs[i][2]) + ")"
			D = log((0.75^-(self.gs[i][0]+self.gs[i][1]+self.gs[i][2])),2)
			T1 = str(self.theta1[i])
			T2 = str(self.theta2[i])
			MRH1 = self.meanCalc(self.rhohat1[i]) #Mean
			SRH1 = self.stdCalc(self.rhohat1[i],MRH1) #STD
			MRH2 = self.meanCalc(self.rhohat2[i]) #Mean
			SRH2 = self.stdCalc(self.rhohat2[i],MRH2) #STD
			MC = self.meanCalc(self.complexities[i]) #Mean
			SC = self.stdCalc(self.complexities[i],MC) #STD
			Tder = MC+D
			
			f.write(G + " & " + str(D) + " & " + T1 + " & " + T2 + " & " + str(MRH1) + " & " + str(SRH1) + " & " + str(MRH2) + " & " + str(SRH2) + " & " + str(MC) + " & " + str(SC) + " & " + str(Tder) + "\\\\\n")
		
		f.write("\\bottomrule\n")
		f.write("\\end{tabular}\n")
		f.write("%\\captionof{table}{}\\label{}\n")
		f.write("\\end{center}\n")
