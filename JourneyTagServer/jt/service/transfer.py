from google.appengine.ext import db

import jt.auth

import datetime

def generateToken(length):
    guid = list(jt.auth.generateLoginToken())
    shortToken = ''
    for index in range(length):
        shortToken += guid[index]

    return shortToken

def validToken(account, token):
    code = db.GqlQuery("SELECT * FROM TransferCode WHERE account = :1 AND token = :2 AND complete = False",account, token).get()
    if code is None:
        return False
    delta = code.dateCreated - datetime.datetime.utcnow()
    if delta.days > 0:
        return False
    return True

def canTransferToUuid(account, uuid):
    if account.uuid == uuid:
        return False

    count = db.GqlQuery("SELECT __key__ FROM TransferCode WHERE account = :1 AND uuid = :2 AND complete = True",account, uuid).count(1)
    return count == 0

def transfer(account, uuid, token):
    account.uuid = uuid
    account.put()
    
    code = db.GqlQuery("SELECT * FROM TransferCode WHERE account = :1 AND token = :2 AND complete = False AND ANCESTOR IS :1",account, token).get()
    code.complete = True
    code.put()