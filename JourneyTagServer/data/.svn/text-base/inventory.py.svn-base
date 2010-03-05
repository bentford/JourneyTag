import os
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper
from jt.auth import jtAuth
from jt.service import *

import logging
class GetAll(webapp.RequestHandler):
  def get(self):
      if not jtAuth.auth(self):
          jtAuth.denied(self)
          return
      query = db.GqlQuery("SELECT * FROM Inventory WHERE account = :1 ORDER BY dateCreated DESC",jtAuth.accountKey(self))
      self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('inventories',query))
     

class Create(webapp.RequestHandler):
  def post(self):
      if not jtAuth.auth(self):
          jtAuth.denied(self)
          return
      key = db.run_in_transaction(jtInventoryService.create,jtAuth.accountKey(self), db.Key(self.request.get('tagKey')) )
      self.response.out.write('{"inventoryKey":"%s"}' % (key) )
                                            

class Delete(webapp.RequestHandler):
  def post(self):
      if not jtAuth.auth(self):
            jtAuth.denied(self)
            return
      key = db.run_in_transaction(jtInventoryService.delete, db.Key(self.request.get('tagKey')), jtAuth.accountKey(self) )
      self.response.out.write('{"inventoryKey":"%s"}' % (key) )

    
application = webapp.WSGIApplication([('/data/inventory/all', GetAll),
								      ('/data/inventory/create', Create),
								      ('/data/inventory/delete',Delete)],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()