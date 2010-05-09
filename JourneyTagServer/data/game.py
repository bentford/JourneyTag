from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper
import jt.service.gameinfo
import logging

class GetAccountsByHighScore(webapp.RequestHandler):
    def get(self):
        accounts = jt.service.gameinfo.getAccountsByHighScore(200)
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('accounts',accounts))

class GetLastTenPhotoKeys(webapp.RequestHandler):
    def get(self):
        photoKeys = jt.service.gameinfo.getLastTenPhotoKeys()
        self.response.out.write(jt.modelhelper.keyArrayToJson('photoKeys',photoKeys))

application = webapp.WSGIApplication([('/data/game/getAccountsByHighScore', GetAccountsByHighScore),
                                      ('/data/game/getLastTenPhotos', GetLastTenPhotoKeys),
								     ],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()