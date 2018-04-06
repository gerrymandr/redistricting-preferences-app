import json, csv

with open('inc_data.json', 'r') as jsfile:
    js = json.load(jsfile)

    with open('states-supplement.csv', 'r') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)

        for state, medinc, medage in reader:
            js[state]["medinc"], js[state]["medage"] = float(medinc), float(medage)

    with open('states-data.json', 'w') as newfile:
        json.dump(js, newfile)
