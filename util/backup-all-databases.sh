#!/bin/bash

set -e
set -u

echo $(date "+%Y-%m-%d %H:%M:%S") Starting up

MYSQLBACKUPDIR=/apps/backup/phdproject/mysql
DBLIST="phdproject phd_development phd_test"

BACKUPDIR=$MYSQLBACKUPDIR/$(date +%Y-%m-%d-%H%M%S)
mkdir -p $BACKUPDIR

for DB in $DBLIST
do
    echo -n "Backing up $DB database... "
    mysqldump -u $DB -p$DB $DB > $BACKUPDIR/$DB.sql
    echo OK
done

echo $(date "+%Y-%m-%d %H:%M:%S") Complete
