# DNS Tunnel

The communication looks like this: Browser --> Local HTTP Proxy --> DNS Server --> Endpoint

All packets are base32 encoded and chunked. So the data could be encapsulated inside the domain name.

## Used for

It can be used to bypass firewalls and other security measures (captitive portals).


## Basic Demonstration

![App Screenshot](https://raw.githubusercontent.com/lightswisp/http_over_dns/master/Drawing1.png)


## How to run

Client side
```bash
  git clone https://github.com/lightswisp/http_over_dns.git
  cd http_over_dns
  cd client
  ruby client.rb <DNS Server IP Address> <Local Port for the Proxy server>
```

Server side (Don't forget to disable the systemd-resolved service)
```bash
 git clone https://github.com/lightswisp/http_over_dns.git
 cd http_over_dns
 cd server
 systemctl stop systemd-resolved
 ruby server.rb
```



    
