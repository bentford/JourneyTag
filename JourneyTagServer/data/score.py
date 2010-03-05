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

class GetPhotoScores(webapp.RequestHandler):
    def get(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
        scores = jtPhotoScoreService.get(jtAuth.accountKey(self))
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('scores',scores))

class GetCarryScores(webapp.RequestHandler):
    def get(self):
        if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
        scores = jtCarryScoreService.get(jtAuth.accountKey(self))
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('scores',scores))

application = webapp.WSGIApplication([('/data/score/getPhotoScores', GetPhotoScores),
                                      ('/data/score/getCarryScores', GetCarryScores)
								     ],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()
    