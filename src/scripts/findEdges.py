# A script to find before-after-edges from India DHS gps data.

from findEdge import findEdge
from findEdgeInsideState import findEdgeInsideState

findEdge('gpsIndiaIncludingStates.csv','gpsIndiaIncludingStatesDistanceToBorder.csv')
findEdgeInsideState('gpsIndiaIncludingStatesDistanceToBorder.csv','gpsIndiaIncludingStatesDistanceToBorderInsideState.csv')