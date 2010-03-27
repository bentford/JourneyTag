from google.appengine.ext import db

import jt.model
import jt.service.inventory
import jt.service.photo
import jt.service.carryscore
import jt.service.mark

import datetime

def delete(tagKey):
    jt.service.inventory.deleteAllForTag(tagKey)
    tag = db.get(tagKey)
    tag.deleted = True
    tag.lastUpdated = datetime.datetime.utcnow()
    tag.put()


def create(accountKey, name, firstCoord, destCoord, destinationAccuracy):
    now = datetime.datetime.utcnow()
    tag = jt.model.Tag(parent=accountKey,
                        account=accountKey,
                        name=name,
                        status='new',
                        currentCoordinate=firstCoord,
                        destinationCoordinate=destCoord,
                        pickedUp=True,
                        distanceTraveled=0,
                        markCount=0,
                        hasReachedDestination=False,
                        dateCreated=now,
                        lastUpdated=now,
                        destinationAccuracy=destinationAccuracy)
    tag.put()
    jt.service.inventory.create(accountKey, tag.key())
    return tag.key()


def dropAndPickup(accountKey, imageData, tag, lat, lon, distanceDelta, newMarkCount, carryScoreIndex):
    current = db.GeoPt(lat=lat, lon=lon)
    tagKey = tag.key()
    
    #create mark before saving tag
    photoKey = jt.service.photo.create(imageData,accountKey,tag.account)
    markKey = jt.service.mark.create(tagKey, lat, lon, photoKey)
    jt.service.inventory.delete(tagKey,accountKey)
    
    tag.currentCoordinate = current
    tag.distanceTraveled += distanceDelta
    tag.markCount = newMarkCount
    tag.pickedUp = True
    tag.lastUpdated = datetime.datetime.utcnow()
    tag.status = 'enabled' #always reset to this

    if not tag.hasReachedDestination:
        distanceFromDestination = jt.location.jtLocation.calculateDistanceInMeters(current.lat, current.lon, tag.destinationCoordinate.lat, tag.destinationCoordinate.lon)
        if distanceFromDestination <= tag.destinationAccuracy:
            tag.hasReachedDestination = True
            tag.dateArrivedAtDestination = datetime.datetime.utcnow()
            tag.status = 'ended'

    tag.put()

    #distanceTraveled!
    tag.account.totalDistanceTraveled += distanceDelta
    tag.account.put()
    
    if accountKey == tag.account.key():
        payout = 0.0
    else:
        payout = tag.account.payout()

    #distanceCarried!
    jt.service.carryscore.addScore(tag.parent_key(), accountKey, markKey, distanceDelta, payout, carryScoreIndex)
    
    jt.service.inventory.create(accountKey,tagKey)
    return tagKey


def dropAtDepot(accountKey, tag, depotKey, distanceDelta, newMarkCount, depotPhotoKey, depotCoordinate, carryScoreIndex):
    randomCoordinate = jt.location.jtLocation.randomCoordinateFromBase(depotCoordinate)
    tagKey = tag.key()
    
    markKey = jt.service.mark.create(tagKey, randomCoordinate.lat, randomCoordinate.lon, depotPhotoKey)
    jt.service.inventory.delete(tagKey,accountKey)
    
    tag.currentCoordinate = randomCoordinate
    tag.distanceTraveled += distanceDelta
    tag.markCount = newMarkCount
    tag.pickedUp = False
    tag.lastUpdated = datetime.datetime.utcnow()
    tag.status = 'enabled' #always reset to this

    if not tag.hasReachedDestination:
        distanceFromDestination = jt.location.jtLocation.calculateDistanceInMeters(randomCoordinate.lat, randomCoordinate.lon, tag.destinationCoordinate.lat, tag.destinationCoordinate.lon)
        if distanceFromDestination <= tag.destinationAccuracy:
            tag.hasReachedDestination = True
            tag.dateArrivedAtDestination = datetime.datetime.utcnow()
            tag.status = 'ended'

    tag.put()
    
    #distanceTraveled!
    tag.account.totalDistanceTraveled += distanceDelta
    tag.account.put()
    
    if accountKey == tag.account.key():
        payout = 0.0
    else:
        payout = tag.account.payout()
    
    #distanceCarried!
    jt.service.carryscore.addScore(tag.parent_key(), accountKey, markKey, distanceDelta, payout, carryScoreIndex)
    
    direction = 0
    if tag.hasReachedDestination:
        direction = 1
    
    depotTagLog = jt.model.DepotTagLog(parent=tagKey,depot=depotKey,tag=tagKey,direction=direction)
    depotTagLog.put()
    
    return tagKey
    

def drop(accountKey, imageData, tag, lat, lon, distanceDelta, newMarkCount, carryScoreIndex):
    current = db.GeoPt(lat=lat, lon=lon)
    tagKey= tag.key()
    
    #create mark before saving tag
    photoKey = jt.service.photo.create(imageData,accountKey,tag.account)
    markKey = jt.service.mark.create(tagKey, lat, lon, photoKey)
    jt.service.inventory.delete(tagKey,accountKey)
    
    tag.currentCoordinate = current
    tag.distanceTraveled += distanceDelta
    tag.markCount = newMarkCount
    tag.pickedUp = False
    tag.lastUpdated = datetime.datetime.utcnow()
    tag.status = 'enabled' #always reset to this
    
    if not tag.hasReachedDestination:
        distanceFromDestination = jt.location.jtLocation.calculateDistanceInMeters(current.lat, current.lon, tag.destinationCoordinate.lat, tag.destinationCoordinate.lon)
        if distanceFromDestination <= tag.destinationAccuracy:
            tag.hasReachedDestination = True
            tag.dateArrivedAtDestination = datetime.datetime.utcnow()
            tag.status = 'ended'

    tag.put()
    
    #distanceTraveled!
    tag.account.totalDistanceTraveled += distanceDelta
    tag.account.put()

    if accountKey == tag.account.key():
        payout = 0.0
    else:
        payout = tag.account.payout()
    
    #distanceCarried!
    jt.service.carryscore.addScore(tag.parent_key(), accountKey, markKey, distanceDelta, payout, carryScoreIndex)
    
    return tagKey


def validateDestinationAccuracy(meters):
    if meters == jt.greatcircle.GreatCircle.milesToMetersRounded(5) or meters == jt.greatcircle.GreatCircle.milesToMetersRounded(1) or meters == 100:
        return meters
    else:
        return jt.gamesettings.defaultDestinationAccuracy


def pickup(accountKey, tagKey):    
    tag = db.get(tagKey)
    
    #final defense against invalid pickups
    if tag.pickedUp is True or tag.deleted is True:
        return False
        
    tag.pickedUp = True
    tag.lastUpdated = datetime.datetime.utcnow()
    
    tag.put()
    
    return jt.service.inventory.create(accountKey,tagKey)


def setCurrentPosition(tagKey, lat, lon):
    tag = db.get(tagKey)
    current = db.GeoPt(lat=lat, lon=lon)
    tag.currentPosition = current
    tag.lastUpdated = datetime.datetime.utcnow()
    
    tag.put()
    return tag.key()


def distanceChangesForDirectDrop(tagKey, newLat, newLon):
    tag = db.get(tagKey)
    lastMark = jt.service.mark.mostRecentMarkForTag(tagKey)
    if lastMark == None:
        distanceDelta = 0
        newMarkCount = 1
        newDistanceTraveled = 0
    else:
        distanceDelta = jt.location.jtLocation.calculateDistance(float(lastMark.coordinate.lat), float(lastMark.coordinate.lon), float(newLat), float(newLon) )

        newMarkCount = tag.markCount + 1
        newDistanceTraveled = tag.distanceTraveled + distanceDelta
    
    return (newMarkCount, newDistanceTraveled, distanceDelta)


def distanceChangesForDepotDrop(tagKey, depotKey):
    tag = db.get(tagKey)
    lastMark = jt.service.mark.mostRecentMarkForTag(tagKey)
    depot = db.get(depotKey)
    if lastMark == None:            
        distanceDelta = 0
    else:
        distanceDelta = jt.location.jtLocation.calculateDistance(float(lastMark.coordinate.lat), float(lastMark.coordinate.lon), float(depot.coordinate.lat), float(depot.coordinate.lon) )
        
    newMarkCount = tag.markCount + 1
    newDistanceTraveled = tag.distanceTraveled + distanceDelta
    
    return (newMarkCount, newDistanceTraveled, distanceDelta)