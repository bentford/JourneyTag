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

class GetAllForTag(webapp.RequestHandler):
  def get(self):
      if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
      query = db.GqlQuery("SELECT * FROM Mark WHERE tag = :1 ORDER BY dateCreated DESC",db.Key(self.request.get('tagKey')))
      marks = []
      for mark in query:
          mark.canVote = mark.photo.takenBy.key() != jtAuth.accountKey(self)
          marks.append(mark)

      self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('marks',marks))

class Create(webapp.RequestHandler):
  def post(self):
      if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
      markKey = db.run_in_transaction(jtMarkService.create, db.Key(self.request.get('tagKey')), self.request.get('lat'), self.request.get('lon'), db.Key(self.request.get('photoKey')) )
      self.response.out.write('{"markKey":"%s"}' % (markKey))
     
application = webapp.WSGIApplication([('/data/mark/getAllForTag', GetAllForTag),
								      ('/data/mark/create', Create)],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()