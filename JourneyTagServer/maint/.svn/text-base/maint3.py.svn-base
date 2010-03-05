import wsgiref.handlers
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
import jt.gamesettings

import logging
import time
import uuid

class CreateAccounts(webapp.RequestHandler):
    def get(self):
        try:
            count = int(self.request.get('count'))
        except:
            count = 10
        
        passGen = jtPassword()
        for index in range(count):
            u = uuid.uuid4().hex
            username = 'user%s_%d' % (passGen.generatePassword(3), index) #using random username
            hashedPassword = jtHashService.hashPassword(passGen.generatePassword(5))
            email = 'blargg27@gmail.com'
            jtAccountService.create(u, username, hashedPassword, email)
            self.response.out.write('created account: %s <br />' % username)
        self.response.out.write('DONE')

def main():
    application = webapp.WSGIApplication([('/maint/maint3/CreateAccounts',CreateAccounts)],
                                         debug=True)
    wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
    main()