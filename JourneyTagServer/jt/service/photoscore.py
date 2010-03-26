from google.appengine.ext import db

import jt.model

import datetime


def addScore(photoKey, takenByAccountKey, parentAccountKey, photoScoreIndex):
    newScore = jt.model.PhotoScore(parent=parentAccountKey, photo=photoKey, account=takenByAccountKey, logDate=datetime.datetime.utcnow(), index=photoScoreIndex )
    newScore.put()

def removeScore(photoKey, takenByAccountKey, parentAccountKey, photoScoreIndex):
    newScore = jt.model.PhotoScore(parent=parentAccountKey, photo=photoKey, account=takenByAccountKey, logDate=datetime.datetime.utcnow(), index=photoScoreIndex, undo=True )
    newScore.put()

def get(accountKey):
    scores = db.GqlQuery("SELECT * FROM PhotoScore WHERE account = :1 ORDER BY logDate DESC",accountKey).fetch(25)
    return scores