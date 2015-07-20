import webapp2

class File(webapp2.RequestHandler):
    def post(self):
        data = self.request.body
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(data)

application = webapp2.WSGIApplication([('/file', File)],debug=True)
