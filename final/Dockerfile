# syntax = docker/dockerfile:1.0-experimental

FROM ruby:3-slim-buster
LABEL maintainer="kris.dekeyser@libis.be"

# Add basic packages
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends --no-show-upgraded build-essential libpq-dev tzdata file \
 && apt-get clean -qq \
 && rm -rf /var/lib/apt/lists/*

# Configure Rails
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true

# Expose Puma port
EXPOSE 3000

# This image is for production env only
ENV RAILS_ENV production

# Add user
ONBUILD ARG USER_NAME=app
ONBUILD ARG GROUP_NAME=app
ONBUILD ARG USER_ID=1000
ONBUILD ARG GROUP_ID=1000
ONBUILD ARG HOME_DIR=/home/app
ONBUILD RUN groupadd --gid ${GROUP_ID} ${GROUP_NAME} && \
            useradd --home-dir ${HOME_DIR} --create-home --no-log-init --uid ${USER_ID} --gid ${GROUP_ID} ${USER_NAME}

# Set application dir
ONBUILD WORKDIR /app

# Copy app with gems from former build stage
ONBUILD COPY --from=builder --chown=${USER_NAME}:${GROUP_NAME} /usr/local/bundle/ /usr/local/bundle/
ONBUILD COPY --from=builder --chown=${USER_NAME}:${GROUP_NAME} /app /app

# Copy the application files
ONBUILD ADD distribution.tar ./

# Install Ruby gems (for production only)
ONBUILD RUN bundle config --local without 'development test' && \
            bundle install --jobs 4 --retry=3 && \
            # Remove unneeded gems
            bundle clean --force && \
            # Remove unneeded files from installed gems (cached *.gem, *.o, *.c)
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete

# Compile assets
# ONBUILD RUN mv config/credentials.yml.enc config/credentials.yml.enc.bak 2>/dev/null || true
# ONBUILD RUN mv config/credentials config/credentials.bak 2>/dev/null || true 
# ONBUILD RUN RAILS_ENV=production \
#             SECRET_KEY_BASE=dummy \
#             RAILS_MASTER_KEY=dummy \
#             bundle exec rails assets:precompile
# ONBUILD RUN mv config/credentials.yml.enc.bak config/credentials.yml.enc 2>/dev/null || true
# ONBUILD RUN mv config/credentials.bak config/credentials 2>/dev/null || true
# ONBUILD RUN bundle exec rails assets::precompile

# Remove folders not needed in resulting image
# ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec app/javascript app/packs
