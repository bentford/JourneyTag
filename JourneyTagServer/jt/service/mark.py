from google.appengine.ext import db

import jt.model

import datetime

def usesPhoto(photoKey):
    count = db.GqlQuery("SELECT __key__ FROM Mark WHERE photo = :1",photoKey).count(1)
    return count == 1

def create(tagKey, lat, lon, photoKey):
    coord = db.GeoPt(lat=lat,lon=lon)
    mark = jt.model.Mark(parent=tagKey,
                      tag=tagKey,
                      dateCreated=datetime.datetime.utcnow(),
                      photo = photoKey,
                      coordinate=coord)
    mark.put()
    return mark.key()


def mostRecentMarkForTag(tagKey):
    return db.GqlQuery("SELECT * FROM Mark WHERE tag = :1 ORDER BY dateCreated DESC", tagKey).get()


def firstMarkForTag(tagKey):
    return db.GqlQuery("SELECT * FROM Mark WHERE tag = :1 ORDER BY dateCreated ASC", tagKey).get()