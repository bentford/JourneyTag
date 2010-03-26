from google.appengine.ext import db

from datetime import datetime
from datetime import timedelta

import uuid


def auth(requestHandler):
    return requestHandler.request.cookies.has_key('JourneyTagID')

def denied(requestHandler):
    requestHandler.response.out.write(' {"response":"AccessDenied"} ')

def setCookie(requestHandler,value):
    cookieDate = datetime.utcnow() + timedelta(days=30)
    cookieDateString = cookieDate.strftime('%a, %d %b %Y %H:%M:%S GMT')
    requestHandler.response.headers.add_header('Set-Cookie','JourneyTagID=%s; expires=%s GMT;path=/;' % (value,cookieDateString))

def accountKey(requestHandler):
    loginToken = requestHandler.request.cookies['JourneyTagID']
    query = db.GqlQuery("SELECT __key__ from Account WHERE loginToken = :1",loginToken)
    account = query.get()
    if account == None:
        return requestHandler.error(404) #404: commonly used when the server does not wish to reveal exactly why the request has been refused
    else:
        return account

def generateLoginToken():
    return str(uuid.uuid4())  #uuid.uuid4().hex
    
    