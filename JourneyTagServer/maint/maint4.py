import wsgiref.handlers
from google.appengine.ext import webapp
from google.appengine.ext import db

import jt.model
import jt.gamesettings
import jt.service.account
import jt.service.carryscoreindex
import maint.worlddata
import jt.location

username = 'TagBot'

class CreateTagBotAccount(webapp.RequestHandler):
    def get(self):
        """ creates account named 'tagbot', if it already exists, nothing will happen """
        
        if jt.service.account.usernameTaken(username):
            accountKey = db.GqlQuery("SELECT __key__ FROM Account WHERE username = :1", username).get()
        else:
            hashedPassword = jt.service.hash.hashPassword('tagbotpassword12345')
            accountKey = db.run_in_transaction(jt.service.account.create, '123456789', username, hashedPassword, 'support@journeytag.com', None )
        
        self.response.out.write('{"accountKey":"%s"}' % accountKey)

class CreateAndDropRandomTag(webapp.RequestHandler):
    def get(self):
        
        accountKey = db.GqlQuery("SELECT __key__ FROM Account WHERE username = :1", username).get()

        (start_name,start_lat,start_lon) = maint.worlddata.get_random_city()
        homeCoord = db.GeoPt(lat=start_lat,lon=start_lon)

        (end_name,end_lat,end_lon) = maint.worlddata.get_random_city()
        randomized_end_coord = jt.location.jtLocation.randomCoordinateFromBase(db.GeoPt(end_lat, end_lon))
        destCoord = db.GeoPt(lat=randomized_end_coord.lat, lon=randomized_end_coord.lon)

        destinationAccuracy = jt.gamesettings.defaultDestinationAccuracy
        name = '%s to %s' % (start_name, end_name)
        tagKey = db.run_in_transaction(jt.service.tag.create, accountKey, name, homeCoord, destCoord, destinationAccuracy )
        
        tag = db.get(tagKey)
        
        (newMarkCount, newDistanceTraveled, distanceDelta) = jt.service.tag.distanceChangesForDirectDrop(tagKey, start_lat, start_lon )
        carryScoreIndex = jt.service.carryscoreindex.incrementIndex(accountKey)
        
        #not sure if this is a random photo, or the first photo
        photo = db.GqlQuery("SELECT * FROM Photo").get()
        
        key = db.run_in_transaction(jt.service.tag.drop,
                               accountKey,
                               photo.data,
                               tag, 
                               start_lat, 
                               start_lon,
                               distanceDelta,
                               newMarkCount,
                               carryScoreIndex)

        self.response.out.write('{"tagKey":"%s", "startCity":"%s", "endCity":"%s" }' % (tagKey, start_name, end_name) )

def main():
    application = webapp.WSGIApplication([('/maint/maint4/CreateTagBotAccount',CreateTagBotAccount),
                                          ('/maint/maint4/CreateAndDropRandomTag',CreateAndDropRandomTag)],
                                         debug=True)

    wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
    main()
