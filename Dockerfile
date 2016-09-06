FROM ruby:2.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
RUN bundle install

COPY . /usr/src/app

EXPOSE 3000
CMD ["rackup", "-o", "0.0.0.0", "-p", "3000", "-s", "thin" ]
