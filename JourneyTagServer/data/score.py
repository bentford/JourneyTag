import os
import datetime

from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper
import jt.service.photoscore

import jt.auth

import logging

class GetPhotoScores(webapp.RequestHandler):
    def get(self):
        if not jt.auth.auth(self):
            jt.auth.denied(self)
            return
        scores = jt.service.photoscore.get(jt.auth.accountKey(self))
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('scores',scores))

class GetCarryScores(webapp.RequestHandler):
    def get(self):
        if not jt.auth.auth(self):
            jt.auth.denied(self)
            return
        scores = jt.service.carryscore.get(jt.auth.accountKey(self))
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('scores',scores))

application = webapp.WSGIApplication([('/data/score/getPhotoScores', GetPhotoScores),
                                      ('/data/score/getCarryScores', GetCarryScores)
								     ],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()
    