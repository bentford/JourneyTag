from google.appengine.ext import db

import jt.model
import jt.service.photoscore

import datetime

def flag(photoKey, flag):
    photo = db.get(photoKey)
    photo.flaggedOffensive = flag
    photo.put()
    
    return photoKey

def like(photoKey, liked, takenByAccountKey, photoScoreIndex):
    photo = db.get(photoKey)
    photo.liked = liked
    photo.put()
    
    if liked is True:
        jt.service.photoscore.addScore(photoKey, takenByAccountKey, photo.parent(), photoScoreIndex)
    else:
        jt.service.photoscore.removeScore(photoKey, takenByAccountKey, photo.parent(), photoScoreIndex)

    return photoKey

def create(data,takenByAccountKey, parentAccountKey):
    photo = jt.model.Photo(parent=parentAccountKey,
                            data=data,
                            dateTaken=datetime.datetime.utcnow(),
                            takenBy=takenByAccountKey
                            )
    photo.put()
    return photo.key()