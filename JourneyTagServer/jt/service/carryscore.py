from google.appengine.ext import db

import jt.model
import datetime

def addScore(parentAccount, account, mark, distanceCarried, payout, index ):
    newScore = jt.model.CarryScore(parent=parentAccount, account=account, mark=mark, distanceCarried=distanceCarried, payout=payout, logDate=datetime.datetime.utcnow(), index=index )
    newScore.put()

def get(accountKey):
    scores = db.GqlQuery("SELECT * FROM CarryScore WHERE account = :1 ORDER BY logDate DESC",accountKey).fetch(25)
    return scores