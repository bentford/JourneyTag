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

class FixCarryScores(webapp.RequestHandler):
  def get(self):
      self.response.out.write('fixing carry scores <br />')
      accounts = jt.model.Account.all()
      for account in accounts:
          self.response.out.write('fixing account: %s <br />' % account.username)
          #delete carryScoreIndex entities
          indexes = db.GqlQuery("SELECT __key__ FROM CarryScoreIndex WHERE account = :1",account)
          db.delete(indexes)

          #get carryScore entities
          scores = db.GqlQuery("SELECT * FROM CarryScore WHERE account = :1",account)
          
          self.response.out.write('found %d scores <br />' % scores.count())
          
          #count and add scores
          count = 0
          total = 0
          for score in scores:
              total += score.carryScore()
              count += 1
              score.index = count
              score.put()
          
          #update account carryScore and lastCarryScoreIndex
          account.carryScore = total
          account.carryScoreLastIndex = count
          account.put()
          
          newIndex = jt.model.CarryScoreIndex(parent=account, account=account, maxIndex=count)
          newIndex.put()
          self.response.out.write(newIndex.maxIndex)

class VerifyCarryScores(webapp.RequestHandler):
    def get(self):
        self.response.out.write('verifying carry scores <br />')
        accounts = jt.model.Account.all()
        for account in accounts:     
            account.computeAndCacheScores() #cache everything   
            self.response.out.write('for account: %d - %s<br />' % (account.key().id(), account.username))
            scores = db.GqlQuery("SELECT * FROM CarryScore WHERE account = :1",account)
            count = 0
            total = 0
            for score in scores:
              total += score.carryScore()
              count += 1
              
            if account.carryScore == total:
              self.response.out.write('carry score OK <br/>')
            else:
              self.response.out.write('carry score WRONG: counted:%d != cached:%d  <br/>' % (total, account.carryScore))

            if account.carryScoreLastIndex == count:
              self.response.out.write('count OK <br/>')
            else:
              self.response.out.write('count WRONG  counted:%d != cached:%d <br/>' % (count, account.carryScoreLastIndex))

class FixPhotoScores(webapp.RequestHandler):
    def get(self):
        self.response.out.write('fixing photo scores <br />')
        accounts = jt.model.Account.all()
        for account in accounts:
            #delete carryScoreIndex entities
            indexes = db.GqlQuery("SELECT __key__ FROM PhotoScoreIndex WHERE account = :1",account)
            db.delete(indexes)

            #get carryScore entities
            scores = db.GqlQuery("SELECT * FROM PhotoScore WHERE account = :1",account)

            #count and add scores
            count = 0
            total = 0
            for score in scores:
                count += 1
                total += score.photoScore()
                score.index = count
                score.put()

            #update account carryScore and lastCarryScoreIndex
            account.photoScore = total
            account.photoScoreLastIndex = count
            account.put()

            newIndex = jt.model.PhotoScoreIndex(parent=account, account=account, maxIndex=count)
            newIndex.put()
            self.response.out.write('fixed account: %s <br />' % account.username)

class VerifyPhotoScores(webapp.RequestHandler):
    def get(self):
        self.response.out.write('verifying photo scores <br />')
        accounts = jt.model.Account.all()
        for account in accounts:     
            account.computeAndCacheScores() #cache everything   
            self.response.out.write('for account: %d - %s<br />' % (account.key().id(), account.username))
            scores = db.GqlQuery("SELECT * FROM PhotoScore WHERE account = :1",account)
            count = 0
            total = 0
            for score in scores:
                count += 1
                total += score.photoScore()
            
            if account.photoScore == total:
              self.response.out.write('carry score OK <br/>')
            else:
              self.response.out.write('carry score WRONG: counted:%d != cached:%d  <br/>' % (total, account.carryScore))

            if account.photoScoreLastIndex == count:
              self.response.out.write('count OK <br/>')
            else:
              self.response.out.write('count WRONG  counted:%d != cached:%d <br/>' % (count, account.carryScoreLastIndex))

def main():
    application = webapp.WSGIApplication([('/maint/maint/VerifyCarryScores', VerifyCarryScores),
                                         ('/maint/maint/FixCarryScores', FixCarryScores),
                                         ('/maint/maint/FixPhotoScores', FixPhotoScores),
                                         ('/maint/maint/VerifyPhotoScores', VerifyPhotoScores)],
                                         debug=True)

    wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
    main()
