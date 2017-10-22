import pysal
import os
import sqlite3

# Gets path for resources
shape_path = os.getcwd()+"/census_data/cb_2016_us_cd115_500k.shp"
data_path = os.getcwd()+"/census_data/cb_2016_us_cd115_500k.dbf"

# Using pysal for parsing
data = pysal.open(data_path)
shapes = pysal.open(shape_path)

districts = []

# id for random selection in app
i = 0

# batches into an array
for dist in data:
    state = int(dist[0])
    district_number = int(dist[1])

    coords = ""
    for vertex in shapes[i].vertices:
        coords += "{},{} ".format(vertex[0], vertex[1])

    districts.append((i, state, district_number, coords.strip()))

    i+=1

# opens a connection; probably should check to see if it already exists...
conn = sqlite3.connect("districts.sql")
curs = conn.cursor()

curs.execute("CREATE TABLE districts (id INTEGER PRIMARY KEY, state INTEGER, number INTEGER, coordinates STRING)")
curs.executemany("INSERT INTO districts VALUES (?, ?, ?, ?)", districts)

conn.commit()
conn.close()