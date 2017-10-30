import plistlib
import os

# Expects the text file available at https://www2.census.gov/geo/docs/reference/state.txt
fips_path = os.getcwd()+"/state.txt"
dump_path = os.getcwd()+"/states.plist"
statesDict = {}

with open(fips_path, 'r') as file:
    _ = file.readline()

    for line in file:
        separated = line.split('|')
        statesDict[separated[0]] = separated[2]

with open(dump_path, 'wb') as dump:
    plistlib.dump(statesDict, dump)