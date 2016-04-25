#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM alpine:3.3
MAINTAINER Andrey Aleksandrov <alex.demion@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------

ENV PORTUS_VERSION="master" \
    NOKOGIRI_USE_SYSTEM_LIBRARIES="1" \
    CATALOG_CRON="5.minutes" \
    COMPOSE=1


#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------

RUN apk --no-cache add --update -t deps git ruby-mini_portile gcc make \
    musl-dev libxml2-dev libxslt-dev mariadb-dev openssl-dev \
    && apk --no-cache add bash ruby-bundler ruby-dev nodejs tzdata libxslt \
    mariadb-libs mariadb-client openssl ruby-io-console ruby-bigdecimal libffi-dev \
    && echo 'gem: --verbose --no-document' > /etc/gemrc; cd /tmp \
    && git clone https://github.com/SUSE/Portus.git . \
    && git checkout ${PORTUS_VERSION}; mkdir /portus \
    && git archive ${PORTUS_VERSION} | tar -xC /portus \
    && git rev-parse --short HEAD > /portus/VERSION; cd /portus \
    && bundle install --retry=3 \
    && apk del --purge deps; rm -rf /tmp/* /var/cache/apk/*

#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------

ADD rootfs /

#------------------------------------------------------------------------------
# Expose ports and entrypoint:
#------------------------------------------------------------------------------

WORKDIR /portus
EXPOSE 443
ENTRYPOINT ["/init"]
