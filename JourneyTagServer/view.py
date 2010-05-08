import wsgiref.handlers

from google.appengine.ext.webapp import template
from google.appengine.ext import webapp
from google.appengine.ext import db
from google.appengine.api import memcache

import jt.sitesettings
import jt.model
import logging
import os
import urllib
import jt.service.gamescore

def durationFromSeconds(seconds):
    if seconds > 60:
        duration = seconds / 60
        timeName = 'minutes'
    else:
        duration = seconds
        timeName = 'seconds'
    return (duration,timeName)

class Photos(webapp.RequestHandler):
    def get(self):
        photos = memcache.get('last_ten_photos')
        if photos is None:
            photos = db.GqlQuery("SELECT __key__ FROM Photo ORDER BY dateTaken DESC").fetch(10)
            memcache.add('last_ten_photos', photos, jt.sitesettings.photoCacheDuration)

        (duration, timeName) = durationFromSeconds(jt.sitesettings.photoCacheDuration)
        
        tPath = os.path.join(os.path.dirname(__file__),'Templates/imagePreview.html')
        self.response.out.write(template.render(tPath,{'photos':photos, 'count':10, 'duration':duration, 'timeName':timeName}))

class HighScores(webapp.RequestHandler):
    def get(self):
        accounts = jt.service.gamescore.getAccountsByHighScore(count=200)
        
        (duration, timeName) = durationFromSeconds(jt.sitesettings.gameStatCache)
        
        tPath = os.path.join(os.path.dirname(__file__),'Templates/highScores.html')
        self.response.out.write(template.render(tPath,{'accounts':accounts, 'count':200, 'duration':duration, 'timeName':timeName}))

class ViewUser(webapp.RequestHandler):
    def get(self):
        username = self.request.path.replace('/view/user/','')
        username = urllib.unquote(username)
        account = db.GqlQuery("SELECT * FROM Account WHERE username = :1",username).get()
        
        tPath = os.path.join(os.path.dirname(__file__),'Templates/viewUser.html')
        self.response.out.write(template.render(tPath,{'account':account, 'computedPhotoScore':account.photoScore*100}))
        
class Stats(webapp.RequestHandler):
    def get(self):
        maintStat = memcache.get('main_stat')
        if maintStat is None:
            maintStat = jt.model.GameStat.get_by_key_name('main_stat')
            memcache.set('main_stat', maintStat, jt.sitesettings.gameStatCache)
        
        
        values = memcache.get('gamestat_chart_values')
        scales = memcache.get('gamestat_chart_scaling')
        if values is None:
            logging.info('did not cache')
            history = jt.model.GameStat.all().order('dateCreated')
        
            accountValues = []
            activeTagValues = []
            finishedTagValues = []
            photoValues = []
            for cur in history:
                accountValues.append(cur.accountTotal)
                activeTagValues.append(cur.activeTagCount)
                finishedTagValues.append(cur.finishedTagCount)
                photoValues.append(cur.photoCount)

            accountScaling = '%d,%d' % self.padScales(min(accountValues),max(accountValues))
            tagScaling = '%d,%d' % self.padScales(min(min(activeTagValues),min(finishedTagValues)), max(max(activeTagValues),max(finishedTagValues)) )
            photoScaling = '%d,%d' % self.padScales(min(photoValues),max(photoValues))
        
            accountValues = ','.join('%s' % i for i in accountValues)
            activeTagValues = ','.join('%s' % i for i in activeTagValues)
            finishedTagValues = ','.join('%s' % i for i in finishedTagValues)
            photoValues = ','.join('%s' % i for i in photoValues)
        
            values = (accountValues, activeTagValues, finishedTagValues, photoValues)
            scales = (accountScaling, tagScaling, photoScaling)
            
            memcache.set('gamestat_chart_values',values,jt.sitesettings.gameStatCache)
            memcache.set('gamestat_chart_scaling', scales, jt.sitesettings.gameStatCache)
        
        accountData = values[0]
        tagData = '|'.join([values[1],values[2]])
        photoData = values[3]
        
        accountScaling = scales[0]
        tagScaling = scales[1]
        photoScaling = scales[2]
        
        
        duration = '24'
        timeName = 'hours'
        tPath = os.path.join(os.path.dirname(__file__),'Templates/viewStats.html')
        self.response.out.write(template.render(tPath,{'stat':maintStat, 'accountData':accountData, 'photoData':photoData, 'tagData':tagData, 'accountScaling':accountScaling, 'tagScaling':tagScaling, 'photoScaling':photoScaling, 'duration':duration, 'timeName':timeName}))
        
    def padScales(self, minimum, maximum):
        r = maximum - minimum
        pad = r * .3
        return (minimum-pad,maximum+pad)

def main():
  application = webapp.WSGIApplication([('/view/stats',Stats),
                                        ('/view/user/.*',ViewUser),
                                        ('/view/photos', Photos),
                                        ('/view/highscores',HighScores)],
                                       debug=True)
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
