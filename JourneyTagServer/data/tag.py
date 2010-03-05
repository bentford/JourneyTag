import os
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper
from jt.auth import jtAuth
from jt.service import *
from jt.location import jtLocation
import jt.wordfilter
import jt.gamesettings

import logging
import time

class DeleteTag(webapp.RequestHandler):
  def post(self):
      if not jtAuth.auth(self):
          jtAuth.denied(self)
          return

      tagKey = db.GqlQuery("SELECT __key__ FROM Tag WHERE __key__ = :1 AND account = :2",db.Key(self.request.get('tagKey')), jtAuth.accountKey(self) ).get()
      if tagKey is None:
          response = '{"response":"Denied"}'
      else:
          db.run_in_transaction(jtTagService.delete, tagKey)
          response = '{"tagKey":"%s"}' % tagKey
      
      self.response.out.write(response)

class GetAllForAccount(webapp.RequestHandler):
  def get(self):
      if not jtAuth.auth(self):
          jtAuth.denied(self)
          return
      query = db.GqlQuery("SELECT * FROM Tag WHERE account = :1 AND deleted = False ORDER BY dateCreated DESC",jtAuth.accountKey(self))
      self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('tags',query))


class Create(webapp.RequestHandler):
  def post(self):
      if not jtAuth.auth(self):
          jtAuth.denied(self)
          return
    
      tagCount = db.GqlQuery("SELECT __key__ FROM Tag WHERE account = :1 AND hasReachedDestination = False AND deleted = False",jtAuth.accountKey(self)).count(jt.gamesettings.activeTagLimit)
      if tagCount == jt.gamesettings.activeTagLimit:
          self.response.out.write('{"response":"LimitReached", "amount":"%s"}' % jt.gamesettings.activeTagLimit )
          return

      homeCoord = db.GeoPt(lat=0,lon=0)
      destCoord = db.GeoPt(lat=self.request.get('destLat'), lon=self.request.get('destLon')) 
      
      destinationAccuracy = int(self.request.get('destinationAccuracy'))
      destinationAccuracy = jtTagService.validateDestinationAccuracy(destinationAccuracy)
      
      name = self.request.get('name').replace('"',"'")
      
      tagKey = db.run_in_transaction(jtTagService.create,jtAuth.accountKey(self), jt.wordfilter.filterWord(name), homeCoord, destCoord, int(destinationAccuracy) )
      self.response.out.write('{"tagKey":"%s"}' % tagKey )
                                            

class Update(webapp.RequestHandler):
  def post(self):
      if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
      t = db.GqlQuery("SELECT * FROM Tag WHERE __key__ = :1 AND account=:2",db.Key(self.request.get('tagKey')), jtAuth.accountKey(self)).get()
      
      if self.request.get('destinationAccuracy') == '':
          destinationAccuracy = jt.gamesettings.defaultDestinationAccuracy
      else:
          destinationAccuracy = int(self.request.get('destinationAccuracy'))
      
      t.name = jt.wordfilter.filterWord(self.request.get('name'))
      t.destinationCoordinate = db.GeoPt(lat=self.request.get('destLat'), lon=self.request.get('destLon'))
      t.destinationAccuracy = destinationAccuracy
      t.problemCode = 0 #reset on any edit
      
      t.put()
      self.response.out.write('{"tagKey":"%s"}' % (t.key()) )

class Drop(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return

        tagKey = db.Key(self.request.get('tagKey'))
        tag = db.get(tagKey)
        
        (newMarkCount, newDistanceTraveled, distanceDelta) = jtTagService.distanceChangesForDirectDrop(tagKey, self.request.get('lat'), self.request.get('lon') )
        carryScoreIndex = jtCarryScoreIndexService.incrementIndex(jtAuth.accountKey(self))
        
        key = db.run_in_transaction(jtTagService.drop,
                                jtAuth.accountKey(self),
                                db.Blob(self.request.get('imageData')),
                                tag, 
                                self.request.get('lat'), 
                                self.request.get('lon'),
                                distanceDelta,
                                newMarkCount,
                                carryScoreIndex)
        
        self.response.out.write('{"tagKey":"%s"}' % key )

class DropAndPickup(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
        tagKey = db.Key(self.request.get('tagKey'))
        tag = db.get(tagKey)
        
        (newMarkCount, newDistanceTraveled, distanceDelta) = jtTagService.distanceChangesForDirectDrop(tagKey, self.request.get('lat'), self.request.get('lon') )
        carryScoreIndex = jtCarryScoreIndexService.incrementIndex(jtAuth.accountKey(self))
        
        key = db.run_in_transaction(jtTagService.dropAndPickup,
                                jtAuth.accountKey(self),
                                db.Blob(self.request.get('imageData')),
                                tag, 
                                self.request.get('lat'), 
                                self.request.get('lon'),
                                distanceDelta,
                                newMarkCount,
                                carryScoreIndex)

        self.response.out.write('{"tagKey":"%s"}' % (key) )
            

class DropAtDepot(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
        
        tagKey = db.Key(self.request.get('tagKey'))
        tag = db.get(tagKey)
        depotKey = db.Key(self.request.get('depotKey'))
        
        (newMarkCount, newDistanceTraveled, distanceDelta) = jtTagService.distanceChangesForDepotDrop(tagKey, depotKey )
        carryScoreIndex = jtCarryScoreIndexService.incrementIndex(jtAuth.accountKey(self))
        
        depot = db.get(depotKey)
        
        key = db.run_in_transaction(jtTagService.dropAtDepot,
                                    jtAuth.accountKey(self),
                                    tag, 
                                    depotKey, 
                                    distanceDelta, 
                                    newMarkCount,
                                    depot.photo.key(),
                                    depot.coordinate,
                                    carryScoreIndex)

        self.response.out.write('{"tagKey":"%s"}' % key )

class Pickup(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
        key = db.run_in_transaction(jtTagService.pickup, jtAuth.accountKey(self), db.Key(self.request.get('tagKey')))
        self.response.out.write('{"tagKey":"%s"}' % key)

class GetForCoordinate(webapp.RequestHandler):
    def get(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
        viewLat = float(self.request.get('viewLat'))
        viewLon = float(self.request.get('viewLon'))
        physicalLat = float(self.request.get('physicalLat'))
        physicalLon = float(self.request.get('physicalLon'))
        

        viewBox = jtLocation.getRangeBoxFromCoordinate(viewLat, viewLon, jt.gamesettings.tagViewRadius)
        pickupBox = jtLocation.getRangeBoxFromCoordinate(physicalLat, physicalLon, jt.gamesettings.tagPickupRadius)
        
        viewQuery = db.GqlQuery("SELECT * FROM Tag WHERE currentCoordinate >= :1 AND currentCoordinate <= :2 AND deleted = False AND pickedUp = False AND hasReachedDestination = False",db.GeoPt(lat=viewBox.minLat, lon=viewBox.minLon), db.GeoPt(lat=viewBox.maxLat, lon=viewBox.maxLon) )
        
        tagList = [] #only because I don't know if I can modify viewQuery in place

        #filter for ability to pickup
        for tag in viewQuery:
            if pickupBox.containsCoordinate( tag.currentCoordinate.lat, tag.currentCoordinate.lon):    
                tag.withinPickupRange = True

            tagList.append(tag)
        
        result = jt.modelhelper.JsonQueryUtil.toArray('tags',tagList)
        self.response.out.write(result)
                           
class GetTag(webapp.RequestHandler):
    def get(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
        accountKey = jtAuth.accountKey(self)
        tag = db.get(db.Key(self.request.get('tagKey')))
        tag.youOwn = accountKey == tag.account.key()
        self.response.out.write(tag.toJSON())

class SetProblemCode(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
        tagKey = db.Key(self.request.get('tagKey'))
        tag = db.get(tagKey)
        tag.problemCode = int(self.request.get('problemCode'))
        tag.put()
        self.response.out.write('{"tagKey":"%s"}' % tagKey)

class CreateTagSeed(webapp.RequestHandler):
    def get(self):
        seed = jt.model.TagSeed(name='Raft the Rogue', location=db.GeoPt(lat=42.434698, lon=-123.169573))
        seed.put()


application = webapp.WSGIApplication([('/data/tag/getAllForAccount', GetAllForAccount),
								      ('/data/tag/create', Create),
								      ('/data/tag/update',Update),
								      ('/data/tag/drop',Drop),
								      ('/data/tag/dropAndPickup',DropAndPickup),
								      ('/data/tag/dropAtDepot',DropAtDepot),
								      ('/data/tag/pickup',Pickup),
								      ('/data/tag/getForCoordinate',GetForCoordinate),
								      ('/data/tag/get',GetTag),
								      ('/data/tag/delete',DeleteTag),
								      ('/data/tag/problem',SetProblemCode),
								      ('/data/tag/tagseed', CreateTagSeed)],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()