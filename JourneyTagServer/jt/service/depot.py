from google.appengine.ext import db

from jt.location import jtLocation
from jt.password import jtPassword

import jt.model
import jt.service.photo
import jt.service.mark
import jt.service.depot

import datetime
import logging
    
def pickup(depotKey, accountKey):
    query = db.GqlQuery("SELECT * FROM Depot WHERE __key__ = :1 AND account = :2 AND ANCESTOR IS :2",depotKey, accountKey)
    depot = query.get()
    
    if jt.service.mark.usesPhoto(depot.photo.key()):
        db.delete(depot.photo)
    
    depot.coordinate = None
    depot.dateDropped = None
    depot.photo = None
    depot.pickedUp = True
    
    depot.put()
    return depotKey

def drop(accountKey, depotKey, lat, lon, imageData):
    photoKey = jt.service.photo.create(imageData,accountKey,accountKey)
    
    query = db.GqlQuery("SELECT * FROM Depot WHERE __key__ = :1 AND account = :2 AND ANCESTOR IS :2",depotKey, accountKey)
    depot = query.get()
    depot.coordinate = db.GeoPt(lat=lat,lon=lon)
    depot.dateDropped = datetime.datetime.utcnow()
    depot.photo = photoKey
    depot.pickedUp = False
    
    depot.put()
    return depot.key()

def getByStatus(accountKey, pickedUp):
    query = db.GqlQuery("SELECT * FROM Depot WHERE account = :1 AND pickedUp = :2",accountKey, pickedUp)
    return query

def getDepotsAsTargetForTag(accountKey, tagKey):
    tag = db.get(tagKey)
    #tag.hasReachedDestination
    direction = 0
    if tag.hasReachedDestination:
        direction = 1

    depotQuery = jt.service.depot.getByStatus(accountKey,False)

    logQuery = db.GqlQuery("SELECT * FROM DepotTagLog WHERE tag = :1",tagKey)

    depotList = []
    for depot in depotQuery:
        status = True
        for logEntry in logQuery:
            if logEntry.depot.key() == depot.key():
                status = False
        depot.tagCanUse = status
        depotList.append(depot)

    return depotList

def create(accountKey,number):
    depot = jt.model.Depot(parent=accountKey, account=accountKey, number=number, pickedUp=True)
    depot.put()
    return depot.key()

def count(accountKey):
    query = db.GqlQuery("SELECT __key__ FROM Depot WHERE account = :1 AND ANCESTOR IS :1",accountKey)
    return query.count()