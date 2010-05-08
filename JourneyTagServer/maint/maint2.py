import wsgiref.handlers
import os
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper
import jt.auth

from jt.location import jtLocation
import jt.gamesettings

import logging
import time

class DeleteArriveScore(webapp.RequestHandler):
  def get(self):
      self.response.out.write('deleting arrive score stuff <br />')
      scores = jt.model.ArriveScore.all()
      db.delete(scores)
      
      indexes = jt.model.ArriveScoreIndex.all()
      db.delete(indexes)
      
      self.response.out.write('DONE <br />')

class UpdateTags(webapp.RequestHandler):
    def get(self):
        self.response.out.write('updating tags')
        tags = jt.model.Tag.all()
        for tag in tags:
            self.response.out.write('updated tag: %s <br />' % tag.name)
            tag.put()
        self.response.out.write('done')

class UpdateAccounts(webapp.RequestHandler):
    def get(self):
        accounts = jt.model.Account.all()
        for account in accounts:
            self.response.out.write('updated tag: %s <br />' % account.username)
            account.computeAndCacheScores()
            account.put()
        self.response.out.write('done')

class CreateTagSeeds(webapp.RequestHandler):
    def get(self):
        jt.model.TagSeed.get_or_insert(key_name='seattle_wa',location=db.GeoPt(lat=47.620772,lon=-122.349387), name='Seattle or Bust')
        jt.model.TagSeed.get_or_insert(key_name='losangelas_ca',location=db.GeoPt(lat=33.836003,lon=-118.052891), name='L.A, here I come')
        jt.model.TagSeed.get_or_insert(key_name='newyork_ny',location=db.GeoPt(lat=40.758764,lon=-73.981571), name='Big Apple!')
        
def main():
    application = webapp.WSGIApplication([('/maint/maint2/CreateTagSeeds',CreateTagSeeds),
                                          ('/maint/maint2/UpdateTags',UpdateTags),
                                          ('/maint/maint2/UpdateAccounts',UpdateAccounts),
                                          ('/maint/maint2/DeleteArriveScore', DeleteArriveScore)],
                                         debug=True)

    wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
    main()
