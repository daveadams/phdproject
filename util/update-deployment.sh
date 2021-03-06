#!/bin/bash

set -e
set -u

SRCDIR=/apps/src/phdproject
APPDIR=/apps/phdproject
UPDATE_DIRS="app bin config lib public"
MYSQLBACKUPDIR=/apps/backup/phdproject/mysql
DBLIST="phd_development phd_test phdproject"

# update source
echo -n "Updating source code... "
cd $SRCDIR
git pull >/dev/null
echo OK

# make sure app is shut down
PSLIST=$(ps aux)
if [ -n "$(grep httpd <<< "$PSLIST")" ] || [ -n "$(grep mongrel <<< "$PSLIST")" ]
then
    echo "ERROR: please stop httpd and mongrel before continuing" >&2
    exit 1
fi

# backup the databases
BACKUPDIR=$MYSQLBACKUPDIR/$(date +%Y-%m-%d-%H%M%S)
mkdir -p $BACKUPDIR

for DB in $DBLIST
do
    echo -n "Backing up $DB database... "
    mysqldump -u $DB -p$DB $DB > $BACKUPDIR/before-$DB.sql
    echo OK
done

# update the databases
cd $SRCDIR
for ENVNAME in development test production
do
    echo -n "Updating the $ENVNAME environment... "
    RAILS_ENV=$ENVNAME rake db:migrate >/dev/null
    RAILS_ENV=$ENVNAME util/update-fixtures.sh >/dev/null
    echo OK
done

# back them up again
for DB in $DBLIST
do
    echo -n "Backing up $DB database... "
    mysqldump -u $DB -p$DB $DB > $BACKUPDIR/after-$DB.sql
    echo OK
done

# wipe and redeploy each directory
cd $APPDIR
for DIR in $UPDATE_DIRS
do
    echo -n "Redeploying $DIR... "
    rm -rf $DIR
    cp -r $SRCDIR/$DIR $DIR
    echo OK
done

echo -n "Updating configuration... "
cd $APPDIR
sed -i 's:/home/da1/per/phd:'$APPDIR':' bin/mongrel.init bin/httpd.init config/httpd.conf
sed -i 's:da1.edtech.vt.edu:phdproject.daveandmollie.com:' config/httpd.conf
echo OK

echo
echo "All done."

# echo -n "Starting mongrel... "
# $APPDIR/bin/mongrel.init start &>/dev/null
# echo OK

# echo -n "Starting httpd... "
# $APPDIR/bin/httpd.init start &>/dev/null
# echo OK


