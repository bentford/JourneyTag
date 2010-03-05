import os
import datetime

from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper

from jt.auth import jtAuth
from jt.service import *
import logging

class GetAllAsTargetForTag(webapp.RequestHandler):
    def get(self):
        if not jtAuth.auth(self):
              jtAuth.denied(self)
              return
        tagKey = db.Key(self.request.get('tagKey'))
        depotList = jtDepotService.getDepotsAsTargetForTag(jtAuth.accountKey(self), tagKey)
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('depots',depotList))

class Get(webapp.RequestHandler):
  def get(self):
      if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
      query = db.GqlQuery("SELECT * FROM Depot WHERE __key__ = :1 AND account = :2",db.Key(self.request.get('depotKey')), jtAuth.accountKey(self))
      depot = query.get()
      self.response.out.write(depot.toJSON())

class GetAllByStatus(webapp.RequestHandler):
    def get(self):
        if not jtAuth.auth(self):
              jtAuth.denied(self)
              return
        pickedUp = self.request.get('pickedUp') == 'True'
        query= jtDepotService.getByStatus(jtAuth.accountKey(self), pickedUp)
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('depots',query))

class Create(webapp.RequestHandler):
  def post(self):
      if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
      
      depotKey = db.run_in_transaction(jtDepotService.create,jtAuth.accountKey(self),9)
      self.response.out.write('{"depotKey":"%s"}' % depotKey )
      
class Drop(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
              jtAuth.denied(self)
              return
        
        depotKey = db.run_in_transaction(jtDepotService.drop,jtAuth.accountKey(self), db.Key(self.request.get('depotKey')), self.request.get('lat'), self.request.get('lon'), db.Blob(self.request.get('imageData')) )
        self.response.out.write('{"depotKey":"%s"}' % depotKey )
        
class Pickup(webapp.RequestHandler):
    def post(self):
        if not jtAuth.auth(self):
              jtAuth.denied(self)
              return
        depotKey = jtDepotService.pickup(db.Key(self.request.get('depotKey')), jtAuth.accountKey(self))
        self.response.out.write('{"depotKey":"%s"}' % depotKey)
                
application = webapp.WSGIApplication([('/data/depot/get', Get),
                                      ('/data/depot/getAllByStatus',GetAllByStatus),
								      ('/data/depot/create', Create),
								      ('/data/depot/drop', Drop),
								      ('/data/depot/pickup',Pickup),
								      ('/data/depot/getAllAsTargetForTag',GetAllAsTargetForTag)
								     ],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()