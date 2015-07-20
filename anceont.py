import webapp2

class MainPage(webapp2.RequestHandler):

    def get(self):
        self.redirect('/s/anceont.html')

application = webapp2.WSGIApplication([
    ('/', MainPage),
], debug=True)
