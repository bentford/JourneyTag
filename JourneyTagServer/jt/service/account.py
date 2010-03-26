from google.appengine.ext import db

import jt.model
import jt.gamesettings
import jt.auth
import jt.service.depot

import datetime
import logging

def changeEmail(account, newEmail):
    account = db.get(account)
    account.email = newEmail
    account.put()

def changePassword(account, newPassword):
    hashedPassword = jt.service.hash.hashPassword(newPassword)
    account.password = hashedPassword
    account.put()

def getUsernamesForPhone(uuid, email):
    query = db.GqlQuery("SELECT * FROM Account WHERE uuid = :1 AND email = :2", uuid, email )
    usernames = []
    for account in query:
        usernames.append(account.username)
    return usernames

def accountForPasswordReset(uuid, username, email):
    return db.GqlQuery("SELECT * FROM Account WHERE uuid = :1 AND username = :2 AND email = :3", uuid, username, email).get()

def resetPassword(account):
    generator = jtPassword()
    newPassword = generator.generatePassword(5)
    changePassword(account, newPassword)

    return newPassword

def accountExists(uuid, username, password):
    query = db.GqlQuery("SELECT * FROM Account WHERE uuid = :1 AND username = :2 AND password = :3", uuid, username, password)
    if query.count(1) == 1:
        return True
    else:
        return False

def usernameTaken(username):
    count = db.GqlQuery("SELECT __key__ FROM Account WHERE username = :1",username).count(1)
    return count == 1


def create(uuid, username, password, email, tagSeed=None):
    token = jt.auth.generateLoginToken()
    acc = jt.model.Account(uuid=uuid,
                        username=username,
                        password=password,
                        loginToken=token,
                        email=email,
                        dateCreated=datetime.datetime.utcnow()
                        )
    acc.put();
    accountKey = acc.key()
    #create two depots initially
    for depotNumber in range(jt.gamesettings.startingDepotCount):
        depotNumber += 1
        jt.service.depot.create(accountKey,depotNumber)

    if tagSeed:
        destinationAccuracy = jt.greatcircle.GreatCircle.milesToMetersRounded(1)
        firstCoord = db.GeoPt(0.0,0.0)
        jt.service.tag.create(acc.key(), tagSeed.name, firstCoord, tagSeed.location, destinationAccuracy)
    return accountKey