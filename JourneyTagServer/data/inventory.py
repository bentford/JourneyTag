import os
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper
import jt.auth


import logging
class GetAll(webapp.RequestHandler):
  def get(self):
      if not jt.auth.auth(self):
          jt.auth.denied(self)
          return
      query = db.GqlQuery("SELECT * FROM Inventory WHERE account = :1 ORDER BY dateCreated DESC",jt.auth.accountKey(self))
      self.response.out.write(jt.modelhelper.JsonQueryUtil.toArray('inventories',query))
     

class Create(webapp.RequestHandler):
  def post(self):
      if not jt.auth.auth(self):
          jt.auth.denied(self)
          return
      key = db.run_in_transaction(jt.service.inventory.create,jt.auth.accountKey(self), db.Key(self.request.get('tagKey')) )
      self.response.out.write('{"inventoryKey":"%s"}' % (key) )
                                            

class Delete(webapp.RequestHandler):
  def post(self):
      if not jt.auth.auth(self):
            jt.auth.denied(self)
            return
      key = db.run_in_transaction(jt.service.inventory.delete, db.Key(self.request.get('tagKey')), jt.auth.accountKey(self) )
      self.response.out.write('{"inventoryKey":"%s"}' % (key) )

    
application = webapp.WSGIApplication([('/data/inventory/all', GetAll),
								      ('/data/inventory/create', Create),
								      ('/data/inventory/delete',Delete)],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()