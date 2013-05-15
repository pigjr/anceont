import webapp2

class File(webapp2.RequestHandler):
    def post(self):
        data = self.request.body
        self.response.headers['Content-Type'] = 'application/json'
        #~ self.response.headers['Content-Disposition'] = 'attachment;filename=\"myAnceont.json\"'
        #~ self.response.write("{\"firstName\":\"Arry\",\"spouse\":[],\"gender\":\"M\",\"children\":[],\"level\":0,\"id\":\"0\",\"lastName\":\"Potter\",\"parents\":[]}")
        #~ self.response.headers['Content-Type'] = entity.mimetype
        #~ self.response.headers['Content-Type'] = 'text/plain'
        #~ self.response.write('Hello, webapp2 World!')
        #~ .setContentType("application/vnd.ms-excel");
        #~ self.response.setHeader("Content-Disposition","attachment; filename=download.xls");
        self.response.out.write(data)

application = webapp2.WSGIApplication([('/file', File)],debug=True)
