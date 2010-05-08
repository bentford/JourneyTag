from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper
import jt.service.gamescore
import logging

class GetAccountsByHighScore(webapp.RequestHandler):
    def get(self):
        accounts = jt.service.gamescore.getAccountsByHighScore(200)
        logging.info('loaded %d accounts' % len(accounts))
        self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('accounts',accounts))

application = webapp.WSGIApplication([('/data/game/getAccountsByHighScore', GetAccountsByHighScore),
								     ],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()