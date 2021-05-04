# syntax = docker/dockerfile:1.0-experimental

FROM ruby:3-buster
LABEL maintainer="kris.dekeyser@kuleuven.be"

# Packages required to build all
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends --no-show-upgraded build-essential wget unzip libpq-dev git tzdata file wget unzip xzip libaio1 \
 && apt-get clean -qq \
 && rm -rf /var/lib/apt/lists/*

# Install Oracle Client
RUN wget -q https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basiclite-linux.x64-21.1.0.0.0.zip \
 && wget -q https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sdk-linux.x64-21.1.0.0.0.zip \
 && unzip -qq instantclient-basiclite-linux.x64-21.1.0.0.0.zip -d /opt/oracle \
 && unzip -qq instantclient-sdk-linux.x64-21.1.0.0.0.zip -d /opt/oracle \
 && mv /opt/oracle/instantclient_21_1 /opt/oracle/instantclient \
 && rm -f instantclient-*-linux.x64-21.1.0.0.0.zip
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient

# Set application dir
WORKDIR /app

# Install default node modules
COPY package.json yarn.lock ./
ENV NODE_VERSION=v14.16.1
ENV NODE_STRING=node-${NODE_VERSION}-linux-x64
RUN wget -q https://nodejs.org/dist/${NODE_VERSION}/${NODE_STRING}.tar.xz \
 && tar -Jxf ${NODE_STRING}.tar.xz -C /usr/local/lib \
 && rm ${NODE_STRING}.tar.xz \
 && ln -s /usr/local/lib/${NODE_STRING} /usr/local/lib/node \
 && ln -s /usr/local/lib/node/bin/node /usr/bin/node \
 && ln -s /usr/local/lib/node/bin/npm /usr/bin/npm \
 && ln -s /usr/local/lib/node/bin/npx /usr/bin/npx \
 && npm install --global yarn \
 && ln -s /usr/local/lib/node/bin/yarn /usr/bin/yarn \
 && yarn install --frozen-lockfile

# Install default gems
COPY Gemfile Gemfile.lock ./
RUN bundle config --local frozen 1 && \
    bundle install -j4 --retry 3 && \
    bundle clean --force && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete
