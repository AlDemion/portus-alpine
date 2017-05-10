#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM alpine
MAINTAINER Andrey Aleksandrov <alex.demion@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------

ENV PORTUS_VERSION="v2.3" \
    NOKOGIRI_USE_SYSTEM_LIBRARIES="1" \
    CATALOG_CRON="5.minutes" \
    COMPOSE=1


#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------

RUN apk --no-cache add --update -t deps \
        git gcc make musl-dev libxml2-dev libxslt-dev \ 
        mariadb-dev libressl-dev libffi-dev \
    && apk --no-cache add \
        bash ruby-bundler ruby-dev nodejs tzdata libxslt mariadb-libs \
        mariadb-client openssl ruby-io-console ruby-bigdecimal \
        mariadb-client-libs curl-dev \
    && echo 'gem: --verbose --no-document' > /etc/gemrc \
    && cd /tmp \
    && git clone https://github.com/SUSE/Portus.git . \
    && git checkout ${PORTUS_VERSION} \
    && mkdir /portus \
    && git archive ${PORTUS_VERSION} | tar -xC /portus \
    && git rev-parse --short HEAD > /portus/VERSION \
    && cd /portus \
    && sed -i 's/mysql2 (0.3.18)/mysql2 (0.4.4)/' Gemfile.lock \
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

