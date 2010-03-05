from google.appengine.ext import db
from google.appengine.api import mail

import jt.model
import jt.gamesettings
from jt.location import jtLocation
from jt.password import jtPassword
from jt.auth import jtAuth


import datetime
import logging

import jt.greatcircle

import hashlib

#all string keys should be converted to real keys before coming in here
#all db.Property() should be converted too

#to stick with YAGNI, i'm only doing what I need

class jtAccountService:
    @staticmethod
    def changeEmail(account, newEmail):
        account = db.get(account)
        account.email = newEmail
        account.put()
    
    @staticmethod
    def changePassword(account, newPassword):
        hashedPassword = jtHashService.hashPassword(newPassword)
        account.password = hashedPassword
        account.put()

    @staticmethod
    def getUsernamesForPhone(uuid, email):
        query = db.GqlQuery("SELECT * FROM Account WHERE uuid = :1 AND email = :2", uuid, email )
        usernames = []
        for account in query:
            usernames.append(account.username)
        return usernames

    @staticmethod
    def accountForPasswordReset(uuid, username, email):
        return db.GqlQuery("SELECT * FROM Account WHERE uuid = :1 AND username = :2 AND email = :3", uuid, username, email).get()

    @staticmethod
    def resetPassword(account):
        generator = jtPassword()
        newPassword = generator.generatePassword(5)
        jtAccountService.changePassword(account, newPassword)

        return newPassword


    @staticmethod
    def accountExists(uuid, username, password):
        query = db.GqlQuery("SELECT * FROM Account WHERE uuid = :1 AND username = :2 AND password = :3", uuid, username, password)
        if query.count(1) == 1:
            return True
        else:
            return False

    @staticmethod
    def usernameTaken(username):
        count = db.GqlQuery("SELECT __key__ FROM Account WHERE username = :1",username).count(1)
        return count == 1

    @staticmethod
    def create(uuid, username, password, email, tagSeed=None):
        token = jtAuth.generateLoginToken()
        acc = jt.model.Account(uuid=uuid,
                            username=username,
                            password=password,
                            loginToken=token,
                            email=email,
                            dateCreated=datetime.datetime.utcnow()
                            )
        acc.put();
        accountKey = acc.key()
        #create two depots initially
        for depotNumber in range(jt.gamesettings.startingDepotCount):
            depotNumber += 1
            jtDepotService.create(accountKey,depotNumber)

        if tagSeed:
            destinationAccuracy = jt.greatcircle.GreatCircle.milesToMetersRounded(1)
            firstCoord = db.GeoPt(0.0,0.0)
            jtTagService.create(acc.key(), tagSeed.name, firstCoord, tagSeed.location, destinationAccuracy)
        return accountKey

class jtDepotService:
    @staticmethod
    def pickup(depotKey, accountKey):
        query = db.GqlQuery("SELECT * FROM Depot WHERE __key__ = :1 AND account = :2 AND ANCESTOR IS :2",depotKey, accountKey)
        depot = query.get()
        
        if jtMarkService.usesPhoto(depot.photo.key()):
            db.delete(depot.photo)
        
        depot.coordinate = None
        depot.dateDropped = None
        depot.photo = None
        depot.pickedUp = True
        
        depot.put()
        return depotKey

    @staticmethod
    def drop(accountKey, depotKey, lat, lon, imageData):
        photoKey = jtPhotoService.create(imageData,accountKey,accountKey)
        
        query = db.GqlQuery("SELECT * FROM Depot WHERE __key__ = :1 AND account = :2 AND ANCESTOR IS :2",depotKey, accountKey)
        depot = query.get()
        depot.coordinate = db.GeoPt(lat=lat,lon=lon)
        depot.dateDropped = datetime.datetime.utcnow()
        depot.photo = photoKey
        depot.pickedUp = False
        
        depot.put()
        return depot.key()
        
    @staticmethod
    def getByStatus(accountKey, pickedUp):
        query = db.GqlQuery("SELECT * FROM Depot WHERE account = :1 AND pickedUp = :2",accountKey, pickedUp)
        return query

    @staticmethod
    def getDepotsAsTargetForTag(accountKey, tagKey):
        tag = db.get(tagKey)
        #tag.hasReachedDestination
        direction = 0
        if tag.hasReachedDestination:
            direction = 1

        depotQuery = jtDepotService.getByStatus(accountKey,False)

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

    @staticmethod
    def create(accountKey,number):
        depot = jt.model.Depot(parent=accountKey, account=accountKey, number=number, pickedUp=True)
        depot.put()
        return depot.key()
    @staticmethod
    def count(accountKey):
        query = db.GqlQuery("SELECT __key__ FROM Depot WHERE account = :1 AND ANCESTOR IS :1",accountKey)
        return query.count()

class jtInventoryService:
    @staticmethod
    def deleteAllForTag(tagKey):
        inventoryKey = db.GqlQuery("SELECT __key__ FROM Inventory WHERE tag = :1 AND ANCESTOR IS :1",tagKey).get()
        if inventoryKey is not None:
            db.delete(inventoryKey)

    @staticmethod
    def delete(tagKey, accountKey):
        inventoryKey = db.GqlQuery("SELECT __key__ FROM Inventory WHERE tag = :1 AND account = :2 AND ANCESTOR IS :1",tagKey, accountKey).get()
        if inventoryKey == None:
            return

        db.delete(inventoryKey)
        return inventoryKey
    @staticmethod
    def create(accountKey, tagKey):
        entity = jt.model.Inventory(parent=tagKey,
                                  account=accountKey,
                                  tag=tagKey,
                                  dateCreated=datetime.datetime.utcnow()
                                  )
        entity.put()
        return entity.key()
        
         
class jtMarkService:
    @staticmethod
    def usesPhoto(photoKey):
        count = db.GqlQuery("SELECT __key__ FROM Mark WHERE photo = :1",photoKey).count(1)
        return count == 1

    @staticmethod
    def create(tagKey, lat, lon, photoKey):
        coord = db.GeoPt(lat=lat,lon=lon)
        mark = jt.model.Mark(parent=tagKey,
                          tag=tagKey,
                          dateCreated=datetime.datetime.utcnow(),
                          photo = photoKey,
                          coordinate=coord)
        mark.put()
        return mark.key()

    @staticmethod
    def mostRecentMarkForTag(tagKey):
        return db.GqlQuery("SELECT * FROM Mark WHERE tag = :1 ORDER BY dateCreated DESC", tagKey).get()
    
    @staticmethod
    def firstMarkForTag(tagKey):
        return db.GqlQuery("SELECT * FROM Mark WHERE tag = :1 ORDER BY dateCreated ASC", tagKey).get()
        
class jtPhotoService:
    @staticmethod
    def flag(photoKey, flag):
        photo = db.get(photoKey)
        photo.flaggedOffensive = flag
        photo.put()
        
        return photoKey

    @staticmethod
    def like(photoKey, liked, takenByAccountKey, photoScoreIndex):
        photo = db.get(photoKey)
        photo.liked = liked
        photo.put()
        
        if liked is True:
            jtPhotoScoreService.addScore(photoKey, takenByAccountKey, photo.parent(), photoScoreIndex)
        else:
            jtPhotoScoreService.removeScore(photoKey, takenByAccountKey, photo.parent(), photoScoreIndex)

        return photoKey

    @staticmethod
    def create(data,takenByAccountKey, parentAccountKey):
        photo = jt.model.Photo(parent=parentAccountKey,
                                data=data,
                                dateTaken=datetime.datetime.utcnow(),
                                takenBy=takenByAccountKey
                                )
        photo.put()
        return photo.key()
        
class jtTagService:
    @staticmethod
    def delete(tagKey):
        jtInventoryService.deleteAllForTag(tagKey)
        tag = db.get(tagKey)
        tag.deleted = True
        tag.lastUpdated = datetime.datetime.utcnow()
        tag.put()

    @staticmethod
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
        jtInventoryService.create(accountKey, tag.key())
        return tag.key()

    @staticmethod
    def dropAndPickup(accountKey, imageData, tag, lat, lon, distanceDelta, newMarkCount, carryScoreIndex):
        current = db.GeoPt(lat=lat, lon=lon)
        tagKey = tag.key()
        
        #create mark before saving tag
        photoKey = jtPhotoService.create(imageData,accountKey,tag.account)
        markKey = jtMarkService.create(tagKey, lat, lon, photoKey)
        jtInventoryService.delete(tagKey,accountKey)
        
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
        jtCarryScoreService.addScore(tag.parent_key(), accountKey, markKey, distanceDelta, payout, carryScoreIndex)
        
        jtInventoryService.create(accountKey,tagKey)
        return tagKey

    @staticmethod
    def dropAtDepot(accountKey, tag, depotKey, distanceDelta, newMarkCount, depotPhotoKey, depotCoordinate, carryScoreIndex):
        randomCoordinate = jt.location.jtLocation.randomCoordinateFromBase(depotCoordinate)
        tagKey = tag.key()
        
        markKey = jtMarkService.create(tagKey, randomCoordinate.lat, randomCoordinate.lon, depotPhotoKey)
        jtInventoryService.delete(tagKey,accountKey)
        
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
        jtCarryScoreService.addScore(tag.parent_key(), accountKey, markKey, distanceDelta, payout, carryScoreIndex)
        
        direction = 0
        if tag.hasReachedDestination:
            direction = 1
        
        depotTagLog = jt.model.DepotTagLog(parent=tagKey,depot=depotKey,tag=tagKey,direction=direction)
        depotTagLog.put()
        
        return tagKey
        
    @staticmethod
    def drop(accountKey, imageData, tag, lat, lon, distanceDelta, newMarkCount, carryScoreIndex):
        current = db.GeoPt(lat=lat, lon=lon)
        tagKey= tag.key()
        
        #create mark before saving tag
        photoKey = jtPhotoService.create(imageData,accountKey,tag.account)
        markKey = jtMarkService.create(tagKey, lat, lon, photoKey)
        jtInventoryService.delete(tagKey,accountKey)
        
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
        jtCarryScoreService.addScore(tag.parent_key(), accountKey, markKey, distanceDelta, payout, carryScoreIndex)
        
        return tagKey

    @staticmethod
    def validateDestinationAccuracy(meters):
        if meters == jt.greatcircle.GreatCircle.milesToMetersRounded(5) or meters == jt.greatcircle.GreatCircle.milesToMetersRounded(1) or meters == 100:
            return meters
        else:
            return jt.gamesettings.defaultDestinationAccuracy

    @staticmethod
    def pickup(accountKey, tagKey):    
        tag = db.get(tagKey)
        
        #final defense against invalid pickups
        if tag.pickedUp is True or tag.deleted is True:
            return False
            
        tag.pickedUp = True
        tag.lastUpdated = datetime.datetime.utcnow()
        
        tag.put()
        
        return jtInventoryService.create(accountKey,tagKey)
    
    @staticmethod
    def setCurrentPosition(tagKey, lat, lon):
        tag = db.get(tagKey)
        current = db.GeoPt(lat=lat, lon=lon)
        tag.currentPosition = current
        tag.lastUpdated = datetime.datetime.utcnow()
        
        tag.put()
        return tag.key()
    
    @staticmethod
    def distanceChangesForDirectDrop(tagKey, newLat, newLon):
        tag = db.get(tagKey)
        lastMark = jtMarkService.mostRecentMarkForTag(tagKey)
        if lastMark == None:
            distanceDelta = 0
            newMarkCount = 1
            newDistanceTraveled = 0
        else:
            distanceDelta = jt.location.jtLocation.calculateDistance(float(lastMark.coordinate.lat), float(lastMark.coordinate.lon), float(newLat), float(newLon) )

            newMarkCount = tag.markCount + 1
            newDistanceTraveled = tag.distanceTraveled + distanceDelta
        
        return (newMarkCount, newDistanceTraveled, distanceDelta)

    @staticmethod
    def distanceChangesForDepotDrop(tagKey, depotKey):
        tag = db.get(tagKey)
        lastMark = jtMarkService.mostRecentMarkForTag(tagKey)
        depot = db.get(depotKey)
        if lastMark == None:            
            distanceDelta = 0
        else:
            distanceDelta = jt.location.jtLocation.calculateDistance(float(lastMark.coordinate.lat), float(lastMark.coordinate.lon), float(depot.coordinate.lat), float(depot.coordinate.lon) )
            
        newMarkCount = tag.markCount + 1
        newDistanceTraveled = tag.distanceTraveled + distanceDelta
        
        return (newMarkCount, newDistanceTraveled, distanceDelta)
        
class jtEmailService:
    @staticmethod
    def emailPassword(toEmail, username, password):
        subject = 'JourneyTag: Password Reset Message'
        body = 'You have requested to reset your password.  Your new login information is in this email.\n\n'
        body += 'Username:  %s \n' % username
        body += 'New password:  %s\n\n' % password
        body += 'Please login to change your password back to something you can remember.'
        mail.send_mail('support@journeytag.com', toEmail, subject, body)
    
    @staticmethod
    def emailUsernames(toEmail, usernames):
        subject = 'JourneyTag: Username Request'
        body = 'Here are a list of usernames registered with your email address on your device.\n'
        for name in usernames:
            body += '-%s \n' % name
            
        mail.send_mail('support@journeytag.com', toEmail, subject, body)
    
    @staticmethod
    def emailTransferCode(toEmail, token):
        subject = 'JourneyTag: Transfer Code Request'
        body = 'You have requested to transfer your account to another device. \n\n Here is your transfer code: %s' % token
        body += '\n\nTo finish this request do the following:'
        body += '\n1) Launch the app on the device you want to transfer to.'
        body += '\n2) Go to the "New Account" screen and press the "Transfer" button.'
        body += '\n3) Enter your credentials'
        body += '\n3) Enter this transfer code: %s' % token
        body += '\n\nRemember: This is a one time operation.  You cannot move your account back to a previous device.'
        body += '\nIf you need to move to a prevous device, go to the website and contact support'
        mail.send_mail('support@journeytag.com', toEmail, subject, body)

class jtPhotoScoreService:
    @staticmethod
    def addScore(photoKey, takenByAccountKey, parentAccountKey, photoScoreIndex):
        newScore = jt.model.PhotoScore(parent=parentAccountKey, photo=photoKey, account=takenByAccountKey, logDate=datetime.datetime.utcnow(), index=photoScoreIndex )
        newScore.put()

    @staticmethod
    def removeScore(photoKey, takenByAccountKey, parentAccountKey, photoScoreIndex):
        newScore = jt.model.PhotoScore(parent=parentAccountKey, photo=photoKey, account=takenByAccountKey, logDate=datetime.datetime.utcnow(), index=photoScoreIndex, undo=True )
        newScore.put()
    
    @staticmethod
    def get(accountKey):
        scores = db.GqlQuery("SELECT * FROM PhotoScore WHERE account = :1 ORDER BY logDate DESC",accountKey).fetch(25)
        return scores
        
class jtCarryScoreService:
    @staticmethod
    def addScore(parentAccount, account, mark, distanceCarried, payout, index ):
        newScore = jt.model.CarryScore(parent=parentAccount, account=account, mark=mark, distanceCarried=distanceCarried, payout=payout, logDate=datetime.datetime.utcnow(), index=index )
        newScore.put()
    
    @staticmethod
    def get(accountKey):
        scores = db.GqlQuery("SELECT * FROM CarryScore WHERE account = :1 ORDER BY logDate DESC",accountKey).fetch(25)
        return scores

class jtPhotoScoreIndexService:
    @staticmethod
    def incrementIndex(parentAccountKey, account):
        index = db.GqlQuery("SELECT * FROM PhotoScoreIndex WHERE ANCESTOR IS :1 AND account = :2",parentAccountKey, account).get()
        if index is None:
            index = jt.model.PhotoScoreIndex(parent=parentAccountKey, account=account, maxIndex=0)
        index.maxIndex += 1
        index.put()
        
        return index.maxIndex
        
class jtCarryScoreIndexService:
    @staticmethod
    def incrementIndex(accountKey):
        index = db.GqlQuery("SELECT * FROM CarryScoreIndex WHERE account = :1", accountKey).get()
        if index is None:
            index = jt.model.CarryScoreIndex(parent=accountKey, account=accountKey, maxIndex=0)
        index.maxIndex += 1
        index.put()
        
        return index.maxIndex

class jtHashService:
    @staticmethod
    def hashPassword(password):
        sha = hashlib.sha1()
        sha.update(password)
        return sha.hexdigest()

class jtTransferService:
    @staticmethod
    def generateToken(length):
        guid = list(jtAuth.generateLoginToken())
        shortToken = ''
        for index in range(length):
            shortToken += guid[index]

        return shortToken

    @staticmethod
    def validToken(account, token):
        code = db.GqlQuery("SELECT * FROM TransferCode WHERE account = :1 AND token = :2 AND complete = False",account, token).get()
        if code is None:
            return False
        delta = code.dateCreated - datetime.datetime.utcnow()
        if delta.days > 0:
            return False
        return True
    
    @staticmethod
    def canTransferToUuid(account, uuid):
        if account.uuid == uuid:
            return False

        count = db.GqlQuery("SELECT __key__ FROM TransferCode WHERE account = :1 AND uuid = :2 AND complete = True",account, uuid).count(1)
        return count == 0
    
    @staticmethod
    def transfer(account, uuid, token):
        account.uuid = uuid
        account.put()
        
        code = db.GqlQuery("SELECT * FROM TransferCode WHERE account = :1 AND token = :2 AND complete = False AND ANCESTOR IS :1",account, token).get()
        code.complete = True
        code.put()

class TagSeedService:
    @staticmethod
    def get():
        from random import uniform
        count = jt.model.TagSeed.all().count()
        if count == 0:
            return None
            
        offset = int(uniform(0,count))
        loc = jt.model.TagSeed.all().fetch(1,offset)[0]
        return loc
