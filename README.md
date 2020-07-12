# DNS over HTTPS (DoH) Server in Docker optimized for Unraid
This is a simple DoH Server for Unraid, it is based on the DoH Server component from: https://github.com/m13253/dns-over-https

You easily can hide your DNS querys from your ISP with this docker on Firefox or Chrome and even on Android with the Intra App (by default it is set to use the Cloudflare and Google DNS servers).

As a special bonus you can hide all Ad's on your Android Device on the go without the need of a VPN (for Android Devices only the Intra App is needed https://getintra.org/)! Very usefull if you have kids and they should not visit certain sites or if you simply don't like Ad's on your Android Device.
All you need is a PiHole, Webserver with an SSL Certificate & this Docker (i highly recommend you for the PiHole Docker: https://hub.docker.com/r/pihole/pihole | for the Webserver: https://hub.docker.com/r/linuxserver/letsencrypt you also can get this two apps in the CA Applications if you are on Unraid):

1. Download PiHole and configure it for your homenetwork for (Bridge mode recommended eg: 192.168.1.5)
2. Download LetsEncrypt and configure it and set up a domain for your dns eg: 'dns.server.net' (Bridge mode recommended eg: 192.168.1.6)
3. Copy the nginx configuration from below in your .../nginx/site-conf/default at the very end and don't forget to change the proxy dns to the DoH-Server (you don't have to do this with a sub domain it also works with the path/location)
4. Download DoH-Server (Bridge mode recommended eg: 192.168.1.7)
5. Edit the 'doh-server.conf' from the main directory and change the Upstream DNS resolver list to your PiHole adress in this example: 192.168.1.5 (there is then only one line and it should look like this: "192.168.1.5:53",)
6. Restart the DoH-Server
7. Download the Intra App on your Android Device
8. On the Intra App go to Settings and click on 'DNS-over-HTTPS-Server' and change it to Custom URL and now type in your URL in this example: 'https://dns.server.net/' note that it must be in that format with 'https://' and the trailing '/' otherwise you can't click 'Accept'
9. Congratulations you are now protected against Ad's on your Android Device.

If you have any questions feel free to ask them on the support thread in the Unraid Forums.

I strongly recommend you to run the container in custom mode and give it a static IP address so that you expose all ports from the container and to avoid any network problems.&#xD; 

Update Notice: If you want to upgrade to a newer version of the DoH-Server just enter the preferred version number (eg. '2.1.2' without quotes, get them from here: https://github.com/m13253/dns-over-https/releases or set it to 'latest' without quotes to check on every startup for a new version)

The Docker runns by default on port: 8053 and handels querys in the directory /dns-query (eg: http://192.168.1.7:8053/dns-query)


>**NOTE:** Please also check out the github page of the creater from DoH: https://github.com/m13253

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DoH_V | Version to install (set 'latest' to install the latest version) | latest |
| GO_DL_URL | The download url for Golang | https://dl.google.com/go/go1.1... |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name DoH-Server -d \
	--env 'DoH_V=latest' \
	--env 'GO_DL_URL=https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz' \
	--env 'UID=99' \
	--env 'GID=100' \
	--volume /mnt/user/appdata/doh-server:/DoH \
    --net=br0 \
    --ip=192.168.1.7 \
    --restart=unless-stopped\
	ich777/doh-server
```
>**NOTE** Please note that i recommend you to run this container in 'Bridge' mode and assign it a dedicated IP adress.


#### nginx configuration for the Linuxserver.io LetsEncrypt Docker (https://hub.docker.com/r/linuxserver/letsencrypt):
```

server {
	listen 443 ssl http2;

	include /config/nginx/ssl.conf;
	include /config/nginx/error.conf;

	server_name dns.server.net;

	location / {
		proxy_pass http://192.168.1.7:8053/dns-query;   ### Please change the IP adress to the DoH-Server IP adress!
		proxy_redirect off;
		proxy_set_header Host $host;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $http_connection;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $remote_addr;
		proxy_set_header X-Forwarded-Protocol $scheme;
		proxy_set_header X-Forwarded-Host $http_host;
		}
}

```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/