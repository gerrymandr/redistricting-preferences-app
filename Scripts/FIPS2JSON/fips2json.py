import json
import os

# Expects the text file available at https://www2.census.gov/geo/docs/reference/state.txt
fips_path = os.getcwd()+"/state.txt"
dump_path = os.getcwd()+"/states.json"
statesDict = {}

with open(fips_path, 'r') as file:
    _ = file.readline()

    for line in file:
        separated = line.split('|')

        stateCode = separated[0]
        if stateCode[0]=="0":
            stateCode=stateCode[1]

        statesDict[stateCode] = separated[2]

with open(dump_path, 'w') as dump:
    json.dump(statesDict, dump)
