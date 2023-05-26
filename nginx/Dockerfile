FROM nginx:stable-alpine3.17
RUN apk add --no-cache aws-cli jq curl

COPY web /var/www/html
COPY ./nginx/bloodbank_docker /root/bloodbank_docker
COPY ./nginx/conf.sh /root/conf.sh
CMD ["sh", "-c", "chmod +x /root/conf.sh && /root/conf.sh "]
