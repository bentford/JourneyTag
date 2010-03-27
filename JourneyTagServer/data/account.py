import os
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

import jt.model
import jt.modelhelper
import jt.auth

import jt.service.hash
import jt.service.tagseed
import jt.service.email
import jt.service.transfer
import jt.service.account

import logging
import datetime

class Login(webapp.RequestHandler):
  def post(self):
      hashedPassword = jt.service.hash.hashPassword(self.request.get('password'))
      query = db.GqlQuery("SELECT * FROM Account WHERE username = :1 AND password = :2 AND uuid = :3",self.request.get('username'), hashedPassword, self.request.get('uuid'))
      account = query.get()

      if account == None:
          count = db.GqlQuery("SELECT __key__ FROM Account WHERE username = :1 AND password = :2",self.request.get('username'), hashedPassword ).count(1)
          if count == 1:
              accountKey = 'WrongPhone'
          else:
              accountKey = 'NotFound'
      else:
          token = jt.auth.generateLoginToken()
          account.loginToken = token
          account.lastLogin = datetime.datetime.utcnow()
          account.put()
          jt.auth.setCookie(self, token)

          accountKey = account.key()
      self.response.out.write('{"accountKey":"%s"}' % accountKey ) 

class Logout(webapp.RequestHandler):
    def get(self):
        if not jt.auth.auth(self):
              jt.auth.denied(self)
              return
        account = db.get(jt.auth.accountKey(self))
        account.loginToken = jt.auth.generateLoginToken() #store new login token, don't tell anybody what it is
        account.put()

        self.response.out.write('{ "response":"Done"} ')

class Create(webapp.RequestHandler):
  def post(self):

    if jt.service.account.usernameTaken(self.request.get('username')):
        accountKey = 'NotUnique'
    else:
        hashedPassword = jt.service.hash.hashPassword(self.request.get('password'))
        tagSeed = jt.service.tagseed.get()
        accountKey = db.run_in_transaction(jt.service.account.create, self.request.get('uuid'), self.request.get('username'), hashedPassword, self.request.get('email'), tagSeed )

    self.response.out.write('{"accountKey":"%s"}' % (accountKey) )

class GetAccountInfo(webapp.RequestHandler):
    def get(self):
        if not jt.auth.auth(self):
              jt.auth.denied(self)
              return
        account = db.get(jt.auth.accountKey(self))

        if account == None:
            self.response.out.write('{"response":"denied"}')
        else:
            self.response.out.write( account.toJSON() )

class ResetPassword(webapp.RequestHandler):
    def post(self):
        account = jt.service.account.accountForPasswordReset(self.request.get('uuid'), self.request.get('username'), self.request.get('email') )
        if account is None:
            self.response.out.write('{ "response":"NoMatch"}')
        else:
            newPassword = jt.service.account.resetPassword(account)
            jt.service.email.emailPassword(account.email, account.username, newPassword )
            self.response.out.write('{ "response":"Match" }')

class ChangePassword(webapp.RequestHandler):
    def post(self):
        if not jt.auth.auth(self):
              jt.auth.denied(self)
              return
        jt.service.account.changePassword(db.get(jt.auth.accountKey(self)),self.request.get('newPassword'))
        self.response.out.write('{"response":"success"}')

class ChangeEmail(webapp.RequestHandler):
    def post(self):
        if not jt.auth.auth(self):
              jt.auth.denied(self)
              return
        newEmail = self.request.get('newEmail')
        if mail.is_email_valid(newEmail):
            jt.service.account.changeEmail(jt.auth.accountKey(self),newEmail)
            self.response.out.write('{"response":"success"}')
        else:
            self.response.out.write('{"response":"invalid", "reason":"%s", "email":"%s"}' % (mail.invalid_email_reason(newEmail), newEmail) )

class GetUsernamesForEmail(webapp.RequestHandler):
    def post(self):
        users = jt.service.account.getUsernamesForPhone(self.request.get('uuid'), self.request.get('email') )
        jt.service.email.emailUsernames(self.request.get('email'), users)

class RequestTransferCode(webapp.RequestHandler):
    def post(self):
        if not jt.auth.auth(self):
              jt.auth.denied(self)
              return

        account = db.get(jt.auth.accountKey(self))
        
        token = jt.service.transfer.generateToken(5)
        code = jt.model.TransferCode(parent=account,account=account, uuid=account.uuid, token=token, dateCreated=datetime.datetime.utcnow())
        code.put()

        jt.service.email.emailTransferCode(account.email, token)
        self.response.out.write('{"response":"success"}')

class TransferAccount(webapp.RequestHandler):
    def post(self):
        hashedPassword = jt.service.hash.hashPassword(self.request.get('password'))  
        query = db.GqlQuery("SELECT * FROM Account WHERE username = :1 AND password = :2 AND email = :3",self.request.get('username'), hashedPassword, self.request.get('email'))
        account = query.get()
        
        if account is None:
            self.response.out.write('{"response":"AccessDenied"}')
            return

        if not jt.service.transfer.canTransferToUuid(account, self.request.get('uuid')):
            self.response.out.write('{"response":"PreviousDevice"}')
            return

        if jt.service.transfer.validToken(account, self.request.get('token')):
            db.run_in_transaction(jt.service.transfer.transfer, account,self.request.get('uuid'), self.request.get('token'))
            self.response.out.write('{"response":"success"}')
        else:
            self.response.out.write('{"response":"failed"}')
        
class LogPiratedUser(webapp.RequestHandler):
    def post(self):
        activity = jt.model.PirateActivity(uuid=self.request.get('uuid') )
        activity.put()
        self.response.out.write('{"response":"OkForNow"}')
        #self.response.out.write('{"response":"CloseApp"}')

application = webapp.WSGIApplication([('/data/account/create', Create),
								      ('/data/account/login', Login),
								      ('/data/account/logout',Logout),
								      ('/data/account/getAccountInfo',GetAccountInfo),
								      ('/data/account/resetPassword',ResetPassword),
								      ('/data/account/changePassword',ChangePassword),
								      ('/data/account/changeEmail', ChangeEmail),
								      ('/data/account/getUsernamesForEmail', GetUsernamesForEmail),
								      ('/data/account/requestTransferCode',RequestTransferCode),
								      ('/data/account/transferAccount', TransferAccount),
								      ('/data/account/reportPirate',LogPiratedUser)],
								      
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()