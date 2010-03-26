from google.appengine.ext import db
import math
import jt.service.mark
import jt.service.depot
from jt.payout import jtPayout
import jt.gamesettings

import datetime
import logging

def formatDate(date): #temporarily doing this here :(
    if date is None:
        return 'None'
    else:
        #return '%s-%s-%s %s:%s:%s' % (date.year, date.month, date.day, date.hour, date.minute, date.second)
        return '%s-%s-%s' % (date.year, date.month, date.day)

def formatDateAsUtc(date):
    if date is None:
        return 'None'
    else:
        return '%s-%s-%s %s:%s:%s -0000' % (date.year, date.month, date.day, date.hour, date.minute, date.second)

class Account(db.Model):
    uuid = db.StringProperty(required=True)
    username = db.StringProperty(required=True)
    password = db.StringProperty(required=True)
    email = db.StringProperty(required=True,default='none')
    loginToken = db.StringProperty(default='')
    
    totalDistanceTraveled = db.IntegerProperty(required=True, default = 0)
    totalDistanceCarried = db.IntegerProperty(required=True, default = 0)
    totalDrops = db.IntegerProperty(required=True, default=0)
    
    carryScore = db.IntegerProperty(required=True, default=0)
    carryScoreLastIndex = db.IntegerProperty(required=True, default=0)
    
    photoScore = db.IntegerProperty(required=True, default=0)
    photoScoreLastIndex = db.IntegerProperty(required=True, default=0)
    
    totalScore = db.IntegerProperty(required=True,default=0)#for creating high score lists only
    
    dateCreated = db.DateTimeProperty(required=True,default=datetime.datetime.utcnow())
    lastLogin = db.DateTimeProperty()
    def toJSON(self):
        self.updateCarryScore()
        self.updatePhotoScore()
        self.awardDepots()
        self.cacheTotalScore()
        return '{"key":"%s", "username":"%s", "totalDistanceTraveled":"%d", "totalDistanceCarried":"%d", "score":"%d", "payout":"%1.2f", "level":"%d", "totalDrops":"%d", "pointsNeededForNextLevel":"%d", "photoScore":"%s", "carryScore":"%s" }' % (self.key(), self.username, self.totalDistanceTraveled, self.totalDistanceCarried, self.computeTotalScore(), self.payout(), self.level(), self.totalDrops, self.pointsNeededForNextLevel(), self.photoScorePoints(), self.carryScore)

    def photoScorePoints(self):
        return self.photoScore * jt.gamesettings.photoVoteAward

    def computeTotalScore(self):
        return self.carryScore + self.photoScorePoints()

    def level(self):
        return jtPayout.calculateLevel(self.computeTotalScore())
    
    def payout(self):
        return jtPayout.calculatePayout(self.computeTotalScore())

    def pointsNeededForNextLevel(self):
        nextLevel = self.level() + 1
        return jtPayout.pointsForLevel(nextLevel) - self.computeTotalScore()
    
    def updateCarryScore(self):
        scores = db.GqlQuery("SELECT * FROM CarryScore WHERE account = :1 AND index > :2 ORDER BY index ASC", self.key(), self.carryScoreLastIndex )
        for score in scores:
            self.totalDrops += 1
            self.carryScore += score.carryScore()
            self.totalDistanceCarried += score.distanceCarried
            self.carryScoreLastIndex += 1
        self.put()

    def updatePhotoScore(self ):
        scores = db.GqlQuery("SELECT * FROM PhotoScore WHERE account = :1 AND index > :2 ORDER BY index ASC", self.key(), self.photoScoreLastIndex )
        for score in scores:
            self.photoScoreLastIndex += 1
            self.photoScore += score.photoScore()
        
        self.put()

    def awardDepots(self):
        level = self.level()
        currentCount = db.GqlQuery("SELECT __key__ FROM Depot WHERE account = :1",self.key()).count(10)
        expectedCount = jt.gamesettings.startingDepotCount
        if (level % 2) == 0:
            expectedCount += level / 2
        else:
            expectedCount += (level - 1 ) / 2
        
        if expectedCount > jt.gamesettings.maxDepotCount:
            expectedCount = jt.gamesettings.maxDepotCount

        while currentCount < expectedCount:
            currentCount += 1
            jt.service.depot.create(self.key(), currentCount)
    
    def cacheTotalScore(self):
        if self.totalScore != self.computeTotalScore():
            self.totalScore = self.computeTotalScore()
            self.put()

class Photo(db.Model):
    data = db.BlobProperty(required=True)
    dateTaken = db.DateTimeProperty(required=True)
    takenBy = db.ReferenceProperty(Account,required=True) #ref
    flaggedOffensive = db.BooleanProperty(required=True,default=False)
    liked = db.BooleanProperty(required=True,default=False)
    _mark = None #helper property, kind of a hack
    def toJSON(self):
        return '{"key":"%s", "dateTaken":"%s", "takenBy":"%s","flaggedOffensive":"%s", "liked":"%s", "coordinate":{"lat":"%s","lon":"%s"} }' % (self.key(), formatDateAsUtc(self.dateTaken), self.takenBy.key(), self.flaggedOffensive, self.liked, self.mark().coordinate.lat, self.mark().coordinate.lon)
    
    def mark(self):
        if self._mark is None:
            self._mark = db.GqlQuery("SELECT * FROM Mark WHERE photo = :1",self.key()).get()
        return self._mark

class Tag(db.Model):
	account = db.ReferenceProperty(Account) #ref
	name = db.StringProperty(required=True)
	status = db.StringProperty(required=True,default='new') #three states (new,enabled,ended)

	destinationCoordinate = db.GeoPtProperty(required=True)
	currentCoordinate = db.GeoPtProperty(required=True)

	pickedUp = db.BooleanProperty(required=True)
	distanceTraveled = db.IntegerProperty(required=True,default=0) #cache
	markCount = db.IntegerProperty(required=True,default=0) #cache
	
	destinationLegDistance = db.IntegerProperty(required=True,default=0) #rename to distanceTraveled
	hasReachedDestination = db.BooleanProperty(required=True,default=False)
	dateArrivedAtDestination = db.DateTimeProperty(required=True,default=datetime.datetime.utcnow())

	dateCreated = db.DateTimeProperty(required=True, default=datetime.datetime.utcnow())
	lastUpdated = db.DateTimeProperty(required=True, default=datetime.datetime.utcnow())
	
	destinationAccuracy = db.IntegerProperty(required=True,default=int(jt.gamesettings.defaultDestinationAccuracy)) #meters
	
	deleted = db.BooleanProperty(required=True,default=False)
	problemCode = db.IntegerProperty(required=True,default=0) #0=none,1=Network,2=NotReachable,3=GpsProblem
	
	withinPickupRange = False #this is a helper property, only used during map loading, doesn't belong here, will move when I think it will work, it is set to value somewhere else because it depends upon currentLocation
	youOwn = False #helper property used during view on map, someday I need to figure where to put these
	def toJSON(self):
	    return '{"key":"%s", "account":"%s", "name":"%s", "status":"%s", "currentCoordinate":{"lat":"%s","lon":"%s"}, "pickedUp":"%s", "distanceTraveled":"%d", "markCount":"%d", "account_username":"%s","payout":"%s", "level":"%s", "withinPickupRange":"%s", "currentDestinationCoordinate":{"lat":"%s","lon":"%s"}, "hasReachedDestination":"%s", "youOwn":"%s", "dateCreated":"%s", "lastUpdated":"%s", "destinationCoordinate":{"lat":"%s","lon":"%s"}, "destinationAccuracy":"%s", "problemCode":"%s" }' % (self.key(), self.account.key(), self.name, self.status, self.currentCoordinate.lat, self.currentCoordinate.lon, self.pickedUp, self.distanceTraveled, self.markCount, self.account.username,self.payout(), self.level(), self.withinPickupRange, self.destinationCoordinate.lat, self.destinationCoordinate.lon, self.hasReachedDestination, self.youOwn, formatDateAsUtc(self.dateCreated), formatDateAsUtc(self.lastUpdated), self.destinationCoordinate.lat, self.destinationCoordinate.lon, self.destinationAccuracy,self.problemCode)

	def payout(self):
	    return jtPayout.calculatePayout(self.account.computeTotalScore())
	
	def level(self):
	    return jtPayout.calculateLevel(self.account.computeTotalScore())

class PhotoScoreIndex(db.Model):
    maxIndex = db.IntegerProperty(required=True,default=0)
    account = db.ReferenceProperty(Account, required=True)

class PhotoScore(db.Model):
    index = db.IntegerProperty(required=True,default=0)
    photo = db.ReferenceProperty(Photo,required=True)
    account = db.ReferenceProperty(Account, required=True)
    logDate = db.DateTimeProperty(required=True)
    undo = db.BooleanProperty(required=True,default=False) #for undo. these minus from score
    def toJSON(self):
        return '{ "logDate":"%s", "photoKey":"%s", "undo":"%s", "photoVoteAward":"%s" }' % ( formatDateAsUtc(self.logDate), self.photo.key(), self.undo, jt.gamesettings.photoVoteAward )
    
    def photoScore(self):
        if self.undo is True:
            return -1
        else:
            return 1

class Mark(db.Model):
    tag = db.ReferenceProperty(Tag,required=True) #ref
    coordinate = db.GeoPtProperty(required=True)
    dateCreated = db.DateTimeProperty(required=True)
    photo = db.ReferenceProperty(Photo, required=True)
    canVote = True #used later, this like like the properties in Tag, go look
    def toJSON(self):
        return '{ "key":"%s", "dateCreated":"%s", "photoKey":"%s", "coordinate":{"lat":"%s","lon":"%s"}, "photoFlaggedOffensive":"%s", "photoLiked":"%s", "canVote":"%s" }' % (self.key(), formatDateAsUtc(self.dateCreated), self.photo.key(),self.coordinate.lat, self.coordinate.lon, self.photo.flaggedOffensive, self.photo.liked, self.canVote)

class CarryScoreIndex(db.Model):
    maxIndex = db.IntegerProperty(required=True,default=0)
    account = db.ReferenceProperty(Account, required=True)

class CarryScore(db.Model):
    index = db.IntegerProperty(required=True,default=0)
    account = db.ReferenceProperty(Account, required=True)
    mark = db.ReferenceProperty(Mark, required=True)
    distanceCarried = db.IntegerProperty(required=True)
    payout = db.FloatProperty(required=True)
    logDate = db.DateTimeProperty(required=True)
    def toJSON(self):
        return '{ "distanceCarried":"%s", "payout":"%s", "logDate":"%s", "tagKey":"%s", "tagName":"%s", "carryScore":"%s" }' % (self.distanceCarried, self.payout, formatDateAsUtc(self.logDate), self.mark.tag.key(), self.mark.tag.name, self.carryScore() ) 

    def carryScore(self):
        total = int(round(self.distanceCarried * self.payout))
        return total

class Depot(db.Model):
    account = db.ReferenceProperty(Account,required=True) #ref
    number = db.IntegerProperty(required=True)
    dateDropped = db.DateTimeProperty()
    coordinate = db.GeoPtProperty()
    photo = db.ReferenceProperty(Photo) #ref
    pickedUp = db.BooleanProperty(required=True)
    tagCanUse = True #another fake property for use not in the model.  I know I should subclass, but where does the child class definiation go?
    def toJSON(self):
        if self.coordinate == None:
            coordinateJson = ''
        else:
            coordinateJson = ', "coordinate":{"lat":"%s","lon":"%s"}' % (self.coordinate.lat, self.coordinate.lon)
        if self.photo == None:
            photoJson = ''
        else:
            photoJson = ', "photo":"%s"' % (self.photo.key())
        return '{"key":"%s", "number":"%s", "dateDropped":"%s", "pickedUp":"%s", "tagCanUse":"%s" %s %s}' % (self.key(), self.number, formatDateAsUtc(self.dateDropped), self.pickedUp, self.tagCanUse, photoJson,coordinateJson)
        
class Inventory(db.Model):
    account = db.ReferenceProperty(Account, required=True)
    tag = db.ReferenceProperty(Tag, required=True)
    dateCreated = db.DateTimeProperty(required=True,default=datetime.datetime.utcnow())
    def toJSON(self):
        return '{"key":"%s", "account":"%s", "tag":"%s", "tagName":"%s", "coordinate":{"lat":"%s","lon":"%s"}, "markCount":"%s", "destinationCoordinate":{"lat":"%s","lon":"%s"}, "payout":"%s", "destinationAccuracy":"%s" }' % (self.key(), self.account.key(), self.tag.key(), self.tag.name, self.tag.currentCoordinate.lat, self.tag.currentCoordinate.lon, self.tag.markCount, self.tag.destinationCoordinate.lat, self.tag.destinationCoordinate.lon, self.tag.payout(), self.tag.destinationAccuracy )

class DepotTagLog(db.Model):
    depot = db.ReferenceProperty(Depot,required=True) #ref
    tag = db.ReferenceProperty(Tag,required=True) #ref

class TransferCode(db.Model):
    account = db.ReferenceProperty(Account, required=True)
    dateCreated = db.DateTimeProperty(required=True, default=datetime.datetime.utcnow())
    token = db.StringProperty(required=True)
    uuid = db.StringProperty(required=True)
    complete = db.BooleanProperty(required=True,default=False)
    
class PirateActivity(db.Model):
    uuid = db.StringProperty(required=True)
    dateLogged = db.DateTimeProperty(required=True,default=datetime.datetime.utcnow())

class GameStat(db.Model):
    accountTotal = db.IntegerProperty(required=True,default=0)
    lastAccountKey = db.StringProperty()

    activeTagCount = db.IntegerProperty(required=True,default=0)
    finishedTagCount = db.IntegerProperty(required=True,default=0)
    
    photoCount = db.IntegerProperty(required=True,default=0)
    lastPhotoKey = db.StringProperty()
    
    dateCreated = db.DateTimeProperty(required=True,default=datetime.datetime.utcnow())
    
class TagSeed(db.Model):
    location = db.GeoPtProperty(required=True)
    name = db.StringProperty(required=True)