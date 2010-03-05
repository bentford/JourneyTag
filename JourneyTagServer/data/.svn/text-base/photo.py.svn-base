import os
import datetime

from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db
from google.appengine.api import memcache

import jt.model
import jt.modelhelper
from jt.auth import jtAuth
from jt.service import *



class GetData(webapp.RequestHandler):
  def get(self):
      #if not jtAuth.auth(self):
            #jtAuth.denied(self)
            #return
      photo = memcache.get("photo_%s" % self.request.get('photoKey'))
      if photo is None:
          photo = db.get(db.Key(self.request.get('photoKey')))
          memcache.add("photo_%s" % self.request.get('photoKey'), photo, 60*60)
      
      self.response.headers['Content-Type'] = 'image/jpeg'
      self.response.out.write(photo.data)

class GetInfo(webapp.RequestHandler):
    def get(self):
        if not jtAuth.auth(self):
              jtAuth.denied(self)
              return
        photo = db.get(db.Key(self.request.get('photoKey')))
        self.response.out.write(photo.toJSON())

class Create(webapp.RequestHandler):
  def post(self):
      if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
      photoKey = db.run_in_transaction(jtPhotoService.create, db.Blob(self.request.get('data')),jtAuth.accountKey(self),jtAuth.accountKey(self))
      self.response.out.write('{"photoKey":"%s"}' % (photoKey))
    
class TakenBy(webapp.RequestHandler):
    def get(self):
        if not jtAuth.auth(self):
              jtAuth.denied(self)
              return
        
        query = db.GqlQuery("SELECT * FROM Photo WHERE takenBy = :1",jtAuth.accountKey(self))
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('photos',query))

class FlagPhoto(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
              jtAuth.denied(self)
              return
        
        flag = self.request.get('flag') == 'True'
        photoKey = db.run_in_transaction(jtPhotoService.flag,db.Key(self.request.get('photoKey')), flag)
        self.response.out.write('{"photoKey":"%s"}' % photoKey)

class LikePhoto(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
              jtAuth.denied(self)
              return

        liked = self.request.get('like') == 'True'
        
        #cannot fetch account key inside transaction
        photo = db.get(db.Key(self.request.get('photoKey')))
        photoScoreIndex = jtPhotoScoreIndexService.incrementIndex(photo.takenBy, photo.takenBy)
        
        photoKey = db.run_in_transaction(jtPhotoService.like, photo.key(), liked, photo.takenBy, photoScoreIndex)
        self.response.out.write('{"photoKey":"%s"}' % photoKey)


application = webapp.WSGIApplication([('/data/photo/getData', GetData),
                                      ('/data/photo/getInfo', GetInfo),
								      ('/data/photo/create', Create),
								      ('/data/photo/takenBy', TakenBy),
								      ('/data/photo/flag',FlagPhoto),
								      ('/data/photo/like',LikePhoto)],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()