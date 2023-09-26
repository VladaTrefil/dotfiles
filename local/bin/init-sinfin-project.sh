#!/bin/bash

database_dir="$HOME/Documents/databases"

if [ -f .env ]; then
  project=$(grep -oP '(?<=PROJECT_NAME=){1}\S*$' .env)
fi

if [ -z "$project" ]; then
  project=${PWD##*/}
fi

env_vars="DB_NAME=${project}_development
          TEST_DB_NAME=${project}_test
          DB_USER=vladislavtrefil
          DB_PASSWORD=1234"

function setup_env() {
  if [ ! -e .env ]; then
    touch .env

    echo "$env_vars" >> .env

    grep -Ev "^(DB_NAME|DB_USER|DB_PASSWORD|TEST_DB_NAME)" .env.sample >> .env
  fi
}

function add_psql_extensions() {
  extensions=$(sed -n 's/enable_extension "\([a-zA-Z_]*\)"/\1/p' db/schema.rb)

  IFS=$'\n'
  for e in $extensions; do
    sudo -u postgres psql -c "CREATE EXTENSION ${e};" "${project}_development"
  done
}

function insert_psql_database_data() {
  db_data_file_path=$( find "$database_dir" -type f -name "$project*.sql.gz" )

  gunzip -ck "$db_data_file_path" > ./db-dump.sql
  psql "${project}_development" < ./db-dump.sql

  bin/rails db:migrate

  rm ./db-dump.sql
}

git pull --rebase
bundle install

setup_env

dropdb "${project}_development"
createdb "${project}_development"

add_psql_extensions
insert_psql_database_data

bundle exec rails runner "eval(File.read '$BIN_PATH/usr/folio-test-account.rb')"
