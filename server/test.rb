require "./http.rb"
include Sender


p Sender.send_request("GET http://example.com/ HTTP/1.1\r\n\Host: example.com\r\nConnection: keep-alive\r\n\r\n", "example.com", "80")
