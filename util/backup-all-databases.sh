#!/bin/bash

set -e
set -u

MYSQLBACKUPDIR=/apps/backup/phdproject/mysql

BACKUPDIR=$MYSQLBACKUPDIR/$(date +%Y-%m-%d-%H%M%S)
mkdir -p $BACKUPDIR

for DB in $DBLIST
do
    echo -n "Backing up $DB database... "
    mysqldump -u $DB -p$DB $DB > $BACKUPDIR/$DB.sql
    echo OK
done
