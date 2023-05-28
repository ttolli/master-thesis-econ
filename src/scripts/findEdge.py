# A script to find out closest neighboring gps cluster that is in a separate
# before-after-group
#
# As an example: if a gps-cluster c is surveyed before March 2020, a
# corresponding distance is a distance to the closest neighboring cluster that
# is surveyed after March 2020. And vice versa if c is surveyed after.
#
# A distance is calculated on great circle. A geodesic distance would be more
# accurate, but is not needed for current purpose as its python implementation
# is too performance incentive. In used distances, great-circle is easily
# accurate enough.
#
# Assumes input .csv data file is in the following form:
# LATNUM, LONGNUM, A, B, C,
# where
# LATNUM    ~ gps latitude
# LONGNUM   ~ gps longitude
# A         ~ 0 if surveyed before March 2020, 1 if after
# B         ~ gps cluster ID
# C         ~ state
#
# Stores result in .cvs which is in the following form:
# LATNUM, LONGNUM, A, B, C, D
# where otherwise as above, and in addition
# D         ~ shortest distance to closest neighboring cluster of different
#             status of A
#
# Arguments:
# datafileIn    ~ input cvs datafile
# datafileOut   ~ output cvs datafile
#
import pandas as pd
import geopy
import geopy.distance

def findEdge(datafileIn, dataFileOut):
    gpsData = pd.read_csv(datafileIn)
    coords = gpsData.values.tolist()
    coords = [x + [0.0] for x in coords];
    ind = 0
    numClusters = len(coords)
    indNewVariable = len(coords[0]) - 1
    for refcoord in coords:
        minDistance = 100000.;
        for coord in coords :
            if (coord[2] != refcoord[2]) :
                # dist = geopy.distance.distance(refcoord[0:2], coord[0:2]).km
                dist = geopy.distance.great_circle(refcoord[0:2], coord[0:2]).km
                if (dist < minDistance) :
                    minDistance = dist
        coords[ind][indNewVariable] = minDistance
        ind = ind + 1
        print(numClusters - ind)
    convertedDf = pd.DataFrame(coords, columns = ['LATNUM','LONGNUM','afterCovidStarted','v001','v024','distanceToBorders'])
    convertedDf.to_csv(dataFileOut, index=False)
