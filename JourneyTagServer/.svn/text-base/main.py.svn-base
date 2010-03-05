import wsgiref.handlers

from google.appengine.ext.webapp import template
from google.appengine.ext import webapp
import os

class MainHandler(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/main.html')
        self.response.out.write(template.render(tPath,{}))

    def head(self):
        pass

class AboutTags(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/aboutTags.html')
        self.response.out.write(template.render(tPath,{}))

class AboutPoints(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/aboutPoints.html')
        self.response.out.write(template.render(tPath,{}))

class AboutDepots(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/aboutDepots.html')
        self.response.out.write(template.render(tPath,{}))

class Support(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/support.html')
        self.response.out.write(template.render(tPath,{}))

class AboutCompany(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/aboutCompany.html')
        self.response.out.write(template.render(tPath,{}))

class SendEmail(webapp.RequestHandler):
    def post(self):
        import jt.email
        jt.email.sendMessage(self.request.get('fromEmail'), self.request.get('message'))
        
        tPath = os.path.join(os.path.dirname(__file__),'Templates/support.html')
        self.response.out.write(template.render(tPath,{'messageSent':True}))

class Sitemap(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/sitemap.xml')
        self.response.out.write(template.render(tPath,{}))

class Robots(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/robots.html')
        self.response.out.write(template.render(tPath,{}))

class Start(webapp.RequestHandler):
    def get(self):
        tPath = os.path.join(os.path.dirname(__file__),'Templates/start.html')
        self.response.out.write(template.render(tPath,{}))

def main():
  application = webapp.WSGIApplication([('/', MainHandler),
                                        ('/about_tags', AboutTags),
                                        ('/about_points', AboutPoints),
                                        ('/about_depots', AboutDepots),
                                        ('/support', Support),
                                        ('/about_company', AboutCompany),
                                        ('/start', Start),
                                        ('/send', SendEmail),
                                        ('/robots.txt',Robots),
                                        ('/sitemap.xml',Sitemap)],
                                       debug=True)
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
