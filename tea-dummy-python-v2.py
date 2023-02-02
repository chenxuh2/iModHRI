# get current directory
import os, sys
print('current working directory: {0}'.format(os.getcwd()))

# add the local python act-r folder to system path
sys.path.insert(0, 'C:/Users/we17lapo/Documents/ACT-R/tutorial/python')

# Note that to connect to ACT-R through the python interface, one must run ACT-R first
# See the following example
import demo2
demo2.experiment()

# Create the model in lisp, and than use the actr.py interface to run the actr model
