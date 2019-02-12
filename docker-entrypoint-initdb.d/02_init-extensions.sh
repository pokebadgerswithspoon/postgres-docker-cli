#!/bin/bash
set -e

echo Enabling uuid-ossp to allow uuid_generate_v4 function
psql -v ON_ERROR_STOP=1 $DB_NAME <<-EOSQL
      CREATE EXTENSION "uuid-ossp";
EOSQL
