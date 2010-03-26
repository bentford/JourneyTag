from google.appengine.ext import db
from google.appengine.api import mail

from jt.location import jtLocation
from jt.password import jtPassword
import jt.model

import datetime
import logging

def deleteAllForTag(tagKey):
    inventoryKey = db.GqlQuery("SELECT __key__ FROM Inventory WHERE tag = :1 AND ANCESTOR IS :1",tagKey).get()
    if inventoryKey is not None:
        db.delete(inventoryKey)

def delete(tagKey, accountKey):
    inventoryKey = db.GqlQuery("SELECT __key__ FROM Inventory WHERE tag = :1 AND account = :2 AND ANCESTOR IS :1",tagKey, accountKey).get()
    if inventoryKey == None:
        return

    db.delete(inventoryKey)
    return inventoryKey

def create(accountKey, tagKey):
    entity = jt.model.Inventory(parent=tagKey,
                              account=accountKey,
                              tag=tagKey,
                              dateCreated=datetime.datetime.utcnow()
                              )
    entity.put()
    return entity.key()