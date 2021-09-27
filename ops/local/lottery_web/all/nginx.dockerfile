
FROM nginx:1.19.8

COPY ./ops/local/lottery_web/all/nginx/nginx.conf /etc/nginx/nginx.conf
