#!/usr/bin/python
import sys
import signal
from threading import Thread
from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler

class TestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        print "---- POST!!! ----"
        print self.headers
        self.send_response(200)

    def do_PUT(self):
        print "----- SOMETHING WAS PUT!! ------"
        print self.headers
        self.send_response(200)

    def do_GET(self):
        print "----- GET!!! ----"
        print self.headers
        self.send_response(304)

def run_on(port):
    print("Starting a server on port %i" % port)
    server_address = ('localhost', port)
    httpd = HTTPServer(server_address, PUTHandler)
    httpd.serve_forever()

server = HTTPServer(('', 8000), TestHandler)
server.serve_forever()
