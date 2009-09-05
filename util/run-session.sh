#!/bin/bash

set -e

PARTICIPANT_COUNT=${1:-20}
COMPLIANCE=${2:-comply}

if [ "$COMPLIANCE" != "comply" ] &&
    [ "$COMPLIANCE" != "nocomply" ] &&
    [ "$COMPLIANCE" != "random" ]
then
    echo "ERROR: Compliance level must be one of 'comply', 'nocomply', or 'random'." >&2
    exit 1
fi

if [ ! -r new-test-session.rb ] || [ ! -r testbot.rb ] || [ ! -r lockdown-current.rb ] ||
    [ ! -r current-audit-count.rb ] || [ ! -r current-is-complete.rb ] ||
    [ ! -x ../script/runner ] || [ ! -w $PWD ]
then
    echo "ERROR: Please check your settings and run from the correct directory." >&2
fi

LOGDIR=logs/$(date +%Y%m%d%H%M%S)
mkdir -p $LOGDIR

../script/runner new-test-session.rb $PARTICIPANT_COUNT

for PN in $(<pn.txt)
do
    echo -n "Starting testbot for $PN... "
    (ruby testbot.rb $PN $COMPLIANCE &>$LOGDIR/$PN.txt &)
    sleep 1
    echo OK
done

rm pn.txt
../script/runner lockdown-current.rb

echo 'Test session underway!'

while [ 1 ]
do
    if ../script/runner current-is-complete.rb
    then
        break
    fi
    echo Waiting...
    sleep 20
done
echo 'Session complete!'

FINAL_PARTICIPANT_COUNT=$(../script/runner 'puts ExperimentalSession.active.participants.count')

if [ $PARTICIPANT_COUNT -ne $FINAL_PARTICIPANT_COUNT ]
then
    echo "ERROR: Only $FINAL_PARTICIPANT_COUNT out of $PARTICIPANT_COUNT participants made it." >&2
fi

AUDIT_COUNT=$(../script/runner 'puts ExperimentalSession.active.participants.find_all_by_audited(true).count')

echo "Audit rate ($COMPLIANCE): $(../script/runner current-audit-count.rb)/$FINAL_PARTICIPANT_COUNT" |tee -a logs/audit-rate-log.txt

echo -n "Closing down session... "
../script/runner 'ExperimentalSession.active.set_complete'
echo OK



