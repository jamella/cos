#Misc
import time
import sys
import random
#import numpy as np
from polybori import substitute_variables


#Initialize Boolean Polynomial Ring
QR = BooleanPolynomialRing(288,names='s',order='lex')
s = QR.gens()
nv = 288;
