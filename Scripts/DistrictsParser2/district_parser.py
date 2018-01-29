import geopandas as gpd
import shapely
import os
import sqlite3
import json
import csv

# Gets path for resources
shape_path = os.getcwd() + "/ShapeFiles/cb_2016_us_cd115_500k.shp"
data_path = os.getcwd() + "/ShapeFiles/cb_2016_us_cd115_500k.dbf"
json_path = os.getcwd() + "/states.json"
demographics_folder_path = os.getcwd() + "/DemographicsData/"

# Using geopandas for parsing
data = gpd.read_file(data_path)

# Load fips codes
j_file = open(json_path, "r")
fips_codes = json.load(j_file)
j_file.close()

districts = []

# id for random selection in app
i = 0

# batches into an array
for _, dist in data.iterrows():
    state_id = str(int(dist["STATEFP"]))
    district_number = int(dist["CD115FP"])

    # if name not in fips database, exclude
    if state_id not in fips_codes:
        continue

    name = fips_codes[state_id]
    filename = demographics_folder_path + "".join(name.split()).lower() + ".csv"

    people = -1
    hispanic = -1
    race = ""
    education = ""
    income = -1
    medage = -1
    medincome = -1

    l_hs = 0

    data_column_index = 3

    if district_number > 1 and district_number != 98:
        data_column_index += 2*(district_number-1)

    try:
        with open(filename, "r") as csv_file:
            csv_reader = csv.reader(csv_file)

            for line in csv_reader:
                if len(line) > data_column_index:
                    if line[1] == "Race":
                        if people == -1:
                            people = int(line[data_column_index])
                        elif "race" not in line[2]:
                            race += line[data_column_index] + ","

                    elif "Hispanic" in line[1] and hispanic == -1 and "Hispanic" in line[2]:
                        hispanic = int(line[data_column_index])

                    elif "Educational" in line[1]:
                        if "Population" not in line[2] and "Percent" not in line[2]:
                            if "9th" in line[2]:
                                l_hs += int(line[data_column_index])
                            else:
                                education += line[data_column_index] + ","

                    elif "Income and Benefits" in line[1]:
                        if "Median" in line[2]:
                            medincome = float(line[data_column_index])

                    elif "Median age" in line[2]:
                        medage = float(line[data_column_index])

    except IOError:
        continue


    shapes = []
    geometry = dist["geometry"]
    if type(geometry) is shapely.geometry.polygon.Polygon:
        shapes.append(geometry)
    else:
        shapes.extend((x for x in geometry))

    coords = []
    for shape in shapes:
        cstr = ""
        for vert in shape.exterior.coords:
            cstr += "{},{} ".format(vert[0], vert[1])

        coords.append(cstr.strip())

    coords_str = "|".join(coords)
    districts.append((i, name, district_number, coords_str, people, hispanic, medage, medincome, race[:-1], str(l_hs) + "," + education[:-1]))

    i += 1

# opens a connection; probably should check to see if it already exists...
conn = sqlite3.connect("districts.sql")
curs = conn.cursor()

# Table format explained:
# id - INTEGER: arbitrarily numbered to allow random selection
# state - STRING: state name
# number - INTEGER: district number
# coordinates - STRING: comma separated vertices of the geographic polygon
# people - INTEGER: total population
# hispanic - INTEGER: number of Hispanic people
# medage - REAL: median age
# medincome - REAL: median income
# race - STRING: comma separated in following order White, A.A, A.I., Asian, N.H.
# education - STRING: comma separated in following order <HS, HS, Some College, 2 yr, 4 yr, Grad


create_statement = ("CREATE TABLE districts (id INTEGER PRIMARY KEY, state INTEGER, number INTEGER, " +
                   "coordinates STRING, people INTEGER, hispanic INTEGER, medage REAL, medincome REAL, " +
                   "race STRING, education STRING)")
curs.execute(create_statement)
curs.executemany("INSERT INTO districts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", districts)

conn.commit()
conn.close()
