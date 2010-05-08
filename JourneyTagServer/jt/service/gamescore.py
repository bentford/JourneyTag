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