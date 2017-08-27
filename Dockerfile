FROM ruby:2.3.1-alpine
MAINTAINER Roman Z <imakegreat.com@gmail.com>


# ENV BUILD_PACKAGES="curl-dev ruby-dev build-dependencies build-base bundler" \
#     DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev sqlite-dev postgresql-dev mysql-dev" \
#     RUBY_PACKAGES="ruby ruby-io-console ruby-json yaml nodejs" \
#     RAILS_VERSION="4.2.6"								

RUN apk --update add --virtual build-dependencies \
								# bundler \
								libcurl \
								curl \
								build-base \
								libxml2-dev \
								libxslt-dev \
								postgresql-dev \
								sqlite-dev \
								nodejs \
								tzdata \
								&& rm -rf /var/cache/apl/*    

# RUN \
#   apk --update --upgrade add $BUILD_PACKAGES $RUBY_PACKAGES $DEV_PACKAGES && \
#   gem install -N bundler								

# RUN gem install -N nokogiri -- --use-system-libraries && \
#   gem install -N rails --version "$RAILS_VERSION" && \
#   echo 'gem: --no-document' >> ~/.gemrc && \
#   cp ~/.gemrc /etc/gemrc && \
#   chmod uog+r /etc/gemrc && \

#   # cleanup and settings
#   bundle config --global build.nokogiri  "--use-system-libraries" && \
#   bundle config --global build.nokogumbo "--use-system-libraries" && \
#   find / -type f -iname \*.apk-new -delete && \
#   rm -rf /var/cache/apk/* && \
#   rm -rf /usr/lib/lib/ruby/gems/*/cache/* && \
#   rm -rf ~/.gem

RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

RUN gem update bundler
RUN bundle install
RUN bundle exec rake assets:precompile
RUN bundle exec rake db:create db:migrate
CMD bundle exec foreman start

EXPOSE 3000  