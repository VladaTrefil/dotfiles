#!/bin/sh

project=${PWD##*/}
db_directory="$HOME/Documents/databases"

git pull --rebase
bundle install

if [ ! -e .env ]; then
  touch .env
  echo "DB_NAME=${project}_development\nDB_USER=vladislavtrefil\nDB_PASSWORD=1234\n" >> .env
  cat .env.sample | grep -Ev "^(DB_NAME|DB_USER|DB_PASSWORD)" >> .env
fi

gunzip -ck "${db_directory}/$( ls $db_directory | grep ${project} | tail -n1 )"

if [ -e $db_sql ]; then
  dropdb ${project}_development
  createdb ${project}_development

  sudo -u postgres psql -c 'CREATE EXTENSION unaccent;' ${project}_development

  psql ${project}_development < ./db-dump.sql

  rm ./db-dump.sql
fi

bin/rails db:migrate
