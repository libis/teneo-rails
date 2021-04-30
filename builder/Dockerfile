FROM ruby:3.0.1-alpine
LABEL maintainer="kris.dekeyser@kuleuven.be"

# Packages required to build all
RUN apk add --nocache build-base postgresql-dev git nodejs yarn tzdata file

WORKDIR /app

# Install default node modules
COPY package.json yarn.lock /app/
RUN yarn install --frozen-lockfile

# Install default gems
COPY Gemfile Gemfile.lock /app/
RUN bundle config --local frozen 1 && \
    bundle install -j4 --retry 3

# Install Ruby gems at build time
ONBUILD COPY Gemfile Gemfile.lock /app/
ONBUILD RUN bundle config --local without 'development test' && \
            bundle install -j4 --retry 3 && \
            # remove unneeded gems
            bundle clean --force && \
            # remove unneeded files from installed gems (cached *.gem *.o *.c)
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete

# Copy the application files
ONBUILD ADD distribution.tar .

# Compile assets
ONBUILD RUN mv config/credentials.yml.enc config/credentials.yml.enc.bak 2>/dev/null || true
ONBUILD RUN mv config/credentials config/credentials.bak 2>/dev/null || true 
ONBUILD RUN RAILS_ENV=production \
            SECRET_KEY_BASE=dummy \
            RAILS_MASTER_KEY=dummy \
            bundle exec rails assets:precompile
ONBUILD RUN mv config/credentials.yml.enc.bak config/credentials.yml.enc 2>/dev/null || true
ONBUILD RUN mv config/credentials.bak config/credentials 2>/dev/null || true

# Remove folders not needed in resulting image
ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec app/javascript app/packs
