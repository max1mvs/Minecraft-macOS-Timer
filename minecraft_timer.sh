#!/bin/bash

# set max time for java/Minecraft to run in minutes
MAX_TIME=60
CURRENT_TIME=$(date +%s)

# check to see if java is running
if (ps aux | grep java | grep -v grep > /dev/null)
  then
    JAVA_IS_RUNNING=true
  else
    JAVA_IS_RUNNING=false
fi

if ($JAVA_IS_RUNNING)
  then
    # check to see if our log file exist
    # if not, we create it
    LOGFILE=/tmp/minecraft-timer-log.txt
    if !(test -f "$LOGFILE")
      then
        # it is not there, so let us create a new temporary file
        LOGFILE=$(mktemp /tmp/minecraft-timer-log.txt)
      else
        # check to see if the file is from yesterday
        LOG_CREATION_DATE=$(stat -f %B $LOGFILE)
        MIDNIGHT=$(($CURRENT_TIME - ($CURRENT_TIME % 86400)))
        if (($MIDNIGHT > $LOG_CREATION_DATE))
          then
            # delete old log file
            rm $LOGFILE
            # create a fresh log file
            LOGFILE=$(mktemp /tmp/minecraft-timer-log.txt)
        fi
    fi
    # read the timestamp from log file, if it exsist
    TEST_LOG=$(<$LOGFILE)
    # see if we have something
    if (test -z "$TEST_LOG")
      then
        # no timestamp found, so we set it to the current time
        echo "LOG_DATESTAMP=$(date +%s)" > "$LOGFILE"
        echo "LOG_TIMER"="0" >> "$LOGFILE"
        echo "LAST_SESSION_TIMER"="0" >> "$LOGFILE"
      else
        # timestamp found
        source $LOGFILE

        # append current time to the timestamp        
        TIME_DIFF=$((CURRENT_TIME - LOG_DATESTAMP))
        TIME_DIFF_MINS=$((TIME_DIFF/60))
        TOTAL_TIME_SPENT=$((TIME_DIFF_MINS + LAST_SESSION_TIMER))

        # check if we have spent too much time
        if !(($TOTAL_TIME_SPENT >= $MAX_TIME))
          then
            # are we close to one minute until time limit then issue a warning
            # give it two minutes if the launch interval is 60 seconds
            WARNING_TIME=$((MAX_TIME-2))
            if (($TOTAL_TIME_SPENT >= $WARNING_TIME))
              then
                # time is up - issuing warning
                osascript -e 'set theDialogText to "Time is up for Minecraft today! Save and quit now, unless you have premission from your parents to continue."
                display dialog theDialogText with icon caution'
            fi
        fi
        # write new timer value in our log file
        sed -i -e "s/LOG_TIMER=.*/LOG_TIMER=${TIME_DIFF_MINS}/" $LOGFILE
    fi
  else
    # if java is not running, and if we have a log file present
    # we need to create a new timestamp in the log so that we can 
    # continue our timer from when java was closed
    LOGFILE=/tmp/minecraft-timer-log.txt
    if (test -f "$LOGFILE")
      then
        # read the file
        source $LOGFILE

        # add LOG_TIMER (current session) to the LAST_SESSION
        NEW_LAST_SESSION_TIME=$((LOG_TIMER + LAST_SESSION_TIMER))
        sed -i -e "s/LAST_SESSION_TIMER=.*/LAST_SESSION_TIMER=${NEW_LAST_SESSION_TIME}/" $LOGFILE

        # reset LOG_TIMER so that it does not constantly get added to the LAST_SESSION
        sed -i -e "s/LOG_TIMER=.*/LOG_TIMER=0/" $LOGFILE

        # write new timestamp value in our log file
        sed -i -e "s/LOG_DATESTAMP=.*/LOG_DATESTAMP=${CURRENT_TIME}/" $LOGFILE
    fi
fi