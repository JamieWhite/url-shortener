# URL Shortener

This is a basic URL shortener where you can create short URL's.

Also supports Slack where you can type slash commands:

##### Add URLS (Slack)
This adds a short URL.

* /addcommand shortURL URL

this calls `/slack/new`

#### List URLS (Slack)
The main index is protected by a token so that it's not public. To get the token:

* /listcommand

this calls `/slack/list`

## Runing via xcode

Needs a `.env` file with the following:

```
DATABASE_HOST=localhost
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=xxxxxxx
DATABASE_NAME=postgres
ADMIN_TOKEN=xxxxxxxxx
INDEX_TOKEN=xxxxxxxxx
SLACK_SIGNING_SECRET=xxxxxxxxxxxx
SLACK_CLIENT_ID=xxxxxxxx
HOSTNAME=example.link
COMMAND=SLACKCOMMAND
```

## Running via Docker

Alternatively install via docker: [https://hub.docker.com/r/jamiewhite/url-shortener](https://hub.docker.com/r/jamiewhite/url-shortener)

```
version: '3.7'

volumes:
  db_data:

x-shared_environment: &shared_environment
  LOG_LEVEL: ${LOG_LEVEL:-debug}
  DATABASE_HOST: db
  DATABASE_NAME: postgres
  DATABASE_USERNAME: postgres
  DATABASE_PASSWORD: xxxxxxxx
  ADMIN_TOKEN: xxxxxxxxx
  INDEX_TOKEN: xxxxxxxxxx
  SLACK_SIGNING_SECRET: xxxxxxxxx
  SLACK_CLIENT_ID: xxxxxxx
  HOSTNAME: example.link
  COMMAND: examplelink

services:
  app:
    image: jamiewhite/url-shortener:latest
    environment:
      <<: *shared_environment
    depends_on:
      - db
    ports:
      - '17606:8080'

  db:
    image: postgres:latest
    volumes:
      - db_data:/var/lib/postgresql/data/pgdata
    environment:
      PGDATA: /var/lib/postgresql/data/pgdata
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: xxxxxxxxxxxxxx
      POSTGRES_DB: postgres