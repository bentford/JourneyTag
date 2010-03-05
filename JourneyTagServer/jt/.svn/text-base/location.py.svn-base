from google.appengine.ext import db
from random import random
from random import uniform

import logging
import math
from jt.greatcircle import GreatCircle

class RangeBox:
    minLon = 0
    maxLon = 0
    minLat = 0
    maxLat = 0

    def __init__(self,minLon,maxLon,minLat,maxLat):
        self.minLon = minLon
        self.maxLon = maxLon
        self.minLat = minLat
        self.maxLat = maxLat

    def containsCoordinate(self, lat, lon):
        latResult = lat >= self.minLat and lat <= self.maxLat
        lonResult = lon >= self.minLon and lon <= self.maxLon

        return latResult and lonResult

        
class jtLocation:
    @staticmethod
    def randomCoordinateFromBase(coordinate):
        lat = coordinate.lat + jtLocation.generateRandomDegree()
        lon = coordinate.lon + jtLocation.generateRandomDegree()
        return db.GeoPt(lat=lat, lon=lon)

    @staticmethod
    def generateRandomDegree():
        degree = int(uniform(.3,1) * 10)
        degree *= .0005
        
        sign = int(random() * 100)
        if (sign % 2) == 0:
            degree *= -1
        return degree

    #accepts coordinates in decimal notation returns distance in miles
    @staticmethod
    def calculateDistance(lat1, lon1, lat2, lon2):
        return GreatCircle.distance(lat1, lon1, lat2, lon2)
    
    @staticmethod
    def calculateDistanceInMeters(lat1, lon1, lat2, lon2):
        return GreatCircle.distanceInMeters(lat1, lon1, lat2, lon2)

    @staticmethod
    def getRangeBoxFromCoordinate(lat, lon, miles):
        minLon = GreatCircle.inverse(miles, 270, lat, lon)[1]
        maxLon = GreatCircle.inverse(miles, 90, lat, lon)[1]
        minLat = GreatCircle.inverse(miles, 180, lat, lon)[0]
        maxLat = GreatCircle.inverse(miles, 0, lat, lon)[0]

        return RangeBox(minLon, maxLon, minLat, maxLat)
        