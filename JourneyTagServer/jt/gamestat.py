from google.appengine.ext import db
from google.appengine.api.labs import taskqueue

import jt.model
import logging
import datetime

COUNT_PAGE_SIZE = 50

def updateGameStatCount(urlPath, keyString, entity, counterAttribute, lastKeyAttribute=None, query=None, whenFinishedUrl=None):
    """Update GameStat-entity by arbitrary-entity
    
    keyString: ie. self.request.get('key') or use None for first request
    entity:  ie. jt.model.Account
    counterAttribute: ie. 'accountTotal'
    lastKeyAttribute: ie. 'lastAccountKey'
    """
    #single instace of GameStat entity
    stat = jt.model.GameStat.get_or_insert('main_stat') 

    if lastKeyAttribute:
        lastAccountKey = getattr(stat, lastKeyAttribute)
    else:
        lastAccountKey = None

    #attempt to recover last stopping point
    if not keyString and lastAccountKey:  
            keyString = lastAccountKey

    if not query:
        query = entity.all(keys_only=True).order('__key__')

    #resume if possible
    if keyString:
        query.filter('__key__ >',db.Key(keyString))
    else:
        #start count over
        setattr(stat,counterAttribute,0)

    repeatRequest = False
    
    #fetch
    entities = query.fetch(COUNT_PAGE_SIZE)
    logging.info('count: %d' % len(entities))
    if len(entities) > 0:
        #if more can entites exist, queue another request
        repeatRequest = len(entities) == COUNT_PAGE_SIZE
    
        #make values
        newCount = getattr(stat,counterAttribute) + len(entities)
        lastKeyString = str(entities[-1])
    
        #update values
        setattr(stat,counterAttribute,newCount)
        if lastKeyAttribute:
            setattr(stat,lastKeyAttribute,lastKeyString)
        
        stat.dateCreated = datetime.datetime.utcnow()
        stat.put()

    #repeat if neccessary
    nextUrl = None
    if repeatRequest:
        nextUrl = '%s?key=%s&whenFinishedUrl=%s' % (urlPath, lastKeyString, whenFinishedUrl)
    elif whenFinishedUrl:
        nextUrl = whenFinishedUrl
    logging.info('nextUrl: %s' % nextUrl)
    if nextUrl:
        t = taskqueue.Task(url=nextUrl, method='GET')
        t.add('count')