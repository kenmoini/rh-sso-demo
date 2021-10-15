FROM registry.redhat.io/rh-sso-7/sso74-openshift-rhel8:7.4

# Add themes
COPY --chown=185:root themes/my-purrina/ /opt/eap/themes/my-purrina/

RUN chmod -R 775 /opt/eap/themes/my-purrina