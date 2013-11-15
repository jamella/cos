#Guess-and-Determine procedure for Trivium to use in sampling resistance

#Main tester


#Reset Screen and Variables
reset();
os.system("clear");

print("Variables have been reset!");

import time
import sys
import random
#import numpy as np
from polybori import substitute_variables


#Initialize Boolean Polynomial Ring
QR = BooleanPolynomialRing(1000,names='s',order='lex')
s = QR.gens()
nv = 288;

load ../equation_construction/polybori_functions.sage
load ../equation_construction/polybori_equation_constructer.sage
load ../equation_construction/verify_with_trivium.sage
load equation_lib.sage
load experiment_lib.sage

ks = 288
[z_no_guess,dummy1,dummy2,dummy3,dummy4,dummy5] = construct_ks_eq(ks,0,0,0);

z = len(z_no_guess)*[0]

x = var('x')

sub_vars_var = [s[i] for i in range(nv)]

count = 0

#No variables are involved in more than one quadratic term in each 
#equation therefore we can simply use substitution with one dummy var
#Otherwise if equations had been higher degree than quadratic and
#or same variable was involved in more than one quadratic term
#we could risk wrongfully cancelling out variables

for i in range(24,93):
	sub_vars_var[i] = s[288]
	count+=1
	
for i in range(96,177):
	sub_vars_var[i] = s[288]
	count+=1
	
for i in range(243,288):
	sub_vars_var[i] = s[288]
	count+=1

for i in range(len(z)):
	z[i] = substitute_variables(QR,sub_vars_var,z_no_guess[i])


S = Sequence(z[:93],QR)
M,v = S.coefficient_matrix()


#M has rank 93, but 42 variables are revealed (first 42) - lets guess these to see how much the reveal
#s[201]-s[242]
for i in range(201,243):
	sub_vars_var[i] = s[288]
	count+=1

for i in range(len(z)):
	z[i] = substitute_variables(QR,sub_vars_var,z_no_guess[i])

#This reveals: s12,..,s23, fix these
for i in range(12,24):
	sub_vars_var[i] = s[288]
	count+=1

for i in range(len(z)):
	z[i] = substitute_variables(QR,sub_vars_var,z_no_guess[i])

#Reveals 189-200, 93-95,6-8, fix these
for i in range(189,201)+range(93,96)+range(6,9):
	sub_vars_var[i] = s[288]
	count+=1
	
for i in range(len(z)):
	z[i] = substitute_variables(QR,sub_vars_var,z_no_guess[i])
	
#Reveals 0-5, 183-185, fix these
for i in range(0,6)+range(183,186):
	sub_vars_var[i] = s[288]
	count+=1
	
for i in range(len(z)):
	z[i] = substitute_variables(QR,sub_vars_var,z_no_guess[i])
	
#Reveals 9-11, 177-182, fix these
for i in range(9,12)+range(177,183):
	sub_vars_var[i] = s[288]
	count+=1
	
for i in range(len(z)):
	z[i] = substitute_variables(QR,sub_vars_var,z_no_guess[i])

S = Sequence(z[:93],QR)
M,v = S.coefficient_matrix()


#Revealed final 3, 186-188
