FROM ruby:3.1.1-alpine3.15

RUN apk update
RUN apk add --no-cache --virtual build-dependencies \
	build-base

RUN mkdir /app
WORKDIR   /app

COPY ./Gemfile      /app
COPY ./Gemfile.lock /app

ENV BUNDLE_PATH /tmp/bundle

RUN bundle

ENV RACK_ENV production
ENV DOCKER   1

COPY . /app

CMD bundle exec rackup -p 9292 -o 0.0.0.0
