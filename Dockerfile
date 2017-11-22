FROM ruby:2.3.1-alpine
MAINTAINER Roman Z <imakegreat.com@gmail.com>

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

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

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