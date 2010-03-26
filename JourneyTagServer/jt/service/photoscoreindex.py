from google.appengine.ext import db

import jt.model

def incrementIndex(parentAccountKey, account):
    index = db.GqlQuery("SELECT * FROM PhotoScoreIndex WHERE ANCESTOR IS :1 AND account = :2",parentAccountKey, account).get()
    if index is None:
        index = jt.model.PhotoScoreIndex(parent=parentAccountKey, account=account, maxIndex=0)
    index.maxIndex += 1
    index.put()
    
    return index.maxIndex