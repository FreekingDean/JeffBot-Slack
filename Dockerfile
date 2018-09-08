FROM ruby:2.3.1-alpine

RUN apk add --update build-base nodejs tzdata openssl git postgresql-dev linux-headers
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

COPY . /app
WORKDIR /app

RUN gem install bundler
RUN bundle install --without development:test --system

CMD ["sh", "-c", "bundle exec ruby app/main.rb"]
