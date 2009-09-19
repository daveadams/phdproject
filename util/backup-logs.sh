#!/bin/bash

set -e
set -u

echo $(date "+%Y-%m-%d %H:%M:%S") Starting up

APPDIR=/apps/phdproject
LOGBACKUPDIR=/apps/backup/phdproject/logs
mkdir -p $LOGBACKUPDIR

echo -n "Creating tarfile... "
LOGTAR=$LOGBACKUPDIR/logbackup-$(date +%Y-%m-%d-%H%M%S).tar
cd $APPDIR
tar cf $LOGTAR log
echo OK

echo -n "Zipping... "
gzip -9 $LOGTAR
echo OK

echo $(date "+%Y-%m-%d %H:%M:%S") Complete
