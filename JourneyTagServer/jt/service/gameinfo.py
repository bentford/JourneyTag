from google.appengine.ext import db
from google.appengine.api import memcache

import jt.model
import jt.sitesettings

def getAccountsByHighScore(count):
	accounts = memcache.get('highscores')
	if accounts is None:
	    accounts = db.GqlQuery("SELECT * FROM Account ORDER BY totalScore DESC").fetch(count)
	    memcache.set('highscores', accounts, jt.sitesettings.gameStatCache)

	return accounts

def getLastTenPhotoKeys():
    photos = memcache.get('last_ten_photos')
    if photos is None:
        photos = db.GqlQuery("SELECT __key__ FROM Photo ORDER BY dateTaken DESC").fetch(10)
        memcache.add('last_ten_photos', photos, jt.sitesettings.photoCacheDuration)
    return photos

def getLastTenPhotos():
    photos = memcache.get('last_ten_photos2')
    if photos is None:
        photos = db.GqlQuery("SELECT * FROM Photo ORDER BY dateTaken DESC").fetch(10)
        memcache.add('last_ten_photos2', photos, jt.sitesettings.photoCacheDuration)
    return photos

def durationFromSeconds(seconds):
    if seconds > 60:
        duration = seconds / 60
        timeName = 'minutes'
    else:
        duration = seconds
        timeName = 'seconds'
    return (duration,timeName)