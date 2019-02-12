#!/bin/sh
exit 
#Not needed i guess

CFG=/var/lib/postgresql/data/pg_hba.conf
TMP=/tmp/editpgconf
#echo "host all all 0.0.0.0/0 trust" >> /var/lib/postgresql/data/pg_hba.conf
sed '$s/md5/trust/' $CFG > $TMP
mv $TMP $CFG
