#!/bin/sh

project=${PWD##*/}
db_directory="$HOME/Documents"

git pull
bundle install

if [ ! -e .env ]; then
  touch .env
  echo "DB_NAME=${project}_development\nDB_USER=vladislavtrefil\nDB_PASSWORD=1234\n" >> .env
  cat .env.sample | grep -Ev "^(DB_NAME|DB_USER|DB_PASSWORD)" >> .env
fi

tar -xvf "${db_directory}/$( ls $db_directory | grep ${project} | tail -n1 )"

db_sql=`ls . | grep -E ${project}.\+.sql`

if [ -e $db_sql ]; then
  dropdb ${project}_development
  createdb ${project}_development

  sudo -u postgres psql -c 'CREATE EXTENSION unaccent;' ${project}_development

  psql ${project}_development < $db_sql

  rm $db_sql
fi

bin/rails db:migrate
