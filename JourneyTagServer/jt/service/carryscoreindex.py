from google.appengine.ext import db

import jt.model

def incrementIndex(accountKey):
    index = db.GqlQuery("SELECT * FROM CarryScoreIndex WHERE account = :1", accountKey).get()
    if index is None:
        index = jt.model.CarryScoreIndex(parent=accountKey, account=accountKey, maxIndex=0)
    index.maxIndex += 1
    index.put()
    
    return index.maxIndex