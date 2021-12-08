FROM quay.io/polyglotsystems/ubi8-nginx:latest as builder

ENV KEYCLOAK_SERVER
ENV KEYCLOAK_REALM
ENV KEYCLOAK_CLIENT_ID
ENV PET_ID_SERVER_ENDPOINT

USER root

#WORKDIR "/opt/app-root/src"
WORKDIR "/var/www/html"

COPY . /var/www/html

RUN npm install \
 && npm run build \
 && chown -R 1001:1001 . \
 && chmod -R 777 .

USER 1001

#FROM registry.access.redhat.com/ubi8/httpd-24:latest
#
#COPY --from=builder /opt/app-root/src/dist/ /var/www/html/dist/
#COPY --from=builder /opt/app-root/src/index.html /var/www/html/index.html
#COPY silent-sso-check.html /var/www/html/silent-sso-check.html