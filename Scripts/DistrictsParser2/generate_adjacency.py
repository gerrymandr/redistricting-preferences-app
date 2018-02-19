import geopandas as gpd
import numpy as np
import shapely
import os
import itertools

data_path = os.getcwd() + "/ShapeFiles/cb_2016_us_cd115_500k.dbf"
data = gpd.read_file(data_path)

def get_polygons(geometry):
    if type(geometry) is shapely.geometry.polygon.Polygon:
        return [geometry]
    else:
        return [shape for shape in geometry]

def check_adjacency(polygons_1, polygons_2):
    for p1, p2 in itertools.product(polygons_1, polygons_2):
        if p1.intersects(p2):
            return True

    return False

adjacency_matrix = np.zeros((len(data),)*2).astype(int)

for i1, i2 in itertools.combinations(range(len(data)), 2):
    polygons_1 = get_polygons(data.ix[i1].geometry)
    polygons_2 = get_polygons(data.ix[i2].geometry)

    d1_fp = int(data.ix[i1].CD115FP)
    d2_fp = int(data.ix[i2].CD115FP)

    if check_adjacency(polygons_1, polygons_2):
        adjacency_matrix[d1_fp, d2_fp] = 1
        adjacency_matrix[d2_fp, d1_fp] = 1 

np.savetxt("adjacency.csv", adjacency_matrix, delimiter=",", newline = "\n")
