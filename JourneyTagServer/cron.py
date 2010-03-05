import wsgiref.handlers
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db
from google.appengine.api.labs import taskqueue

import jt.model
import jt.gamesettings
import jt.sitesettings
import jt.gamestat

import logging
import datetime

PAGE_SIZE = jt.sitesettings.tagTimeoutBatchSize
COUNT_PAGE_SIZE = 50

class TagTimeout(webapp.RequestHandler):
    def get(self):
        key = self.request.get('key')
        if key:
            query = db.GqlQuery("SELECT * FROM Inventory WHERE __key__ > :1 ORDER BY __key__", db.Key(key))
        else:
            query = db.GqlQuery("SELECT * FROM Inventory ORDER BY __key__")

        newKey = None
        inventories = query.fetch(PAGE_SIZE+1)
        if len(inventories) == PAGE_SIZE+1:
            newKey = str(inventories[-1].key())

        for inventory in inventories:
            span = datetime.datetime.utcnow() - inventory.dateCreated
            if inventory.tag.status != 'new' and span.days > jt.gamesettings.autoDropTagDays:
                inventory.tag.pickedUp = False
                inventory.tag.lastUpdated = datetime.datetime.utcnow()
                inventory.tag.put()
                
                db.delete(inventory)


        if newKey:
            nextUrl = '/cron/tag_timeout?key=%s' % newKey
        else:
            nextUrl = None
        
        if nextUrl:
            taskqueue.add(url=nextUrl, method='GET')

class AccountTotalCount(webapp.RequestHandler):
    def get(self):
        whenFinishedUrl = self.request.get('whenFinishedUrl')
        if not whenFinishedUrl:
            whenFinishedUrl = '/cron/photo_count'
        jt.gamestat.updateGameStatCount(self.request.path, self.request.get('key'), jt.model.Account, 'accountTotal', 'lastAccountKey', None, whenFinishedUrl)

class PhotoCount(webapp.RequestHandler):
    def get(self):
        whenFinishedUrl = self.request.get('whenFinishedUrl')
        if not whenFinishedUrl:
            whenFinishedUrl = '/cron/active_tag_count'
        jt.gamestat.updateGameStatCount(self.request.path, self.request.get('key'), jt.model.Photo, 'photoCount', 'lastPhotoKey', None, whenFinishedUrl)

class ActiveTagCount(webapp.RequestHandler):
    def get(self):
        whenFinishedUrl = self.request.get('whenFinishedUrl')        
        if not whenFinishedUrl:
            whenFinishedUrl = '/cron/finished_tag_count'
        query = jt.model.Tag.all(keys_only=True)
        query.filter('hasReachedDestination',False)
        query.filter('deleted',False)
        jt.gamestat.updateGameStatCount(self.request.path, self.request.get('key'), jt.model.Tag, 'activeTagCount', None, query, whenFinishedUrl)

class FinishedTagCount(webapp.RequestHandler):
    def get(self):
        whenFinishedUrl = self.request.get('whenFinishedUrl')        
        if not whenFinishedUrl:
            whenFinishedUrl = '/cron/archive_gamestat'
        
        query = jt.model.Tag.all(keys_only=True)
        query.filter('hasReachedDestination',True)
        query.filter('deleted',False)
        jt.gamestat.updateGameStatCount(self.request.path, self.request.get('key'), jt.model.Tag, 'finishedTagCount', None, query, whenFinishedUrl)

class ArchiveGameStats(webapp.RequestHandler):
    def get(self):
        mainStat = jt.model.GameStat.get_by_key_name('main_stat')
        now = datetime.datetime.utcnow()
        dateKeyName = '%d-%d-%d' % (now.year, now.month, now.day)
        datedStat =jt.model.GameStat.get_or_insert(dateKeyName)
        
        datedStat.accountTotal = mainStat.accountTotal
        datedStat.activeTagCount = mainStat.activeTagCount
        datedStat.finishedTagCount = mainStat.finishedTagCount
        datedStat.photoCount = mainStat.photoCount
        
        datedStat.put()

def main():
    application = webapp.WSGIApplication([('/cron/tag_timeout', TagTimeout),
                                          ('/cron/account_total_count', AccountTotalCount),
                                          ('/cron/photo_count', PhotoCount),
                                          ('/cron/active_tag_count', ActiveTagCount),
                                          ('/cron/finished_tag_count', FinishedTagCount),
                                          ('/cron/archive_gamestat', ArchiveGameStats)],
                                         debug=True)

    wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
    main()
