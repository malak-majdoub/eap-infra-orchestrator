#!/bin/bash

docker run -d \
  --name nginx \
  --restart unless-stopped \
  --network eap-dev-network \
  --network eap-test-network \
  --network eap-prod-network \
  -p 80:80 \
  -p 443:443 \
  -v /opt/nginx/conf.d:/etc/nginx/conf.d:ro \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  -v /home/motopp/playwright-report:/playwright-report:ro \
  -v /home/motopp/uptime-report:/uptime-report:ro \
  -v /etc/nginx/.htpasswd:/etc/nginx/.htpasswd:ro \
  nginx:latest