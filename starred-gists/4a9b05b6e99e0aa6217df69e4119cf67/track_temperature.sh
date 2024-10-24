#!/bin/bash
# logs the temperature every minute
# sends a message if it is too high or low or if it can't be measured
# also sends a message at a given time every day

#sensor ID (must be a DS18B20 sensor)
SENSOR_ID="28-011453d372aa"
# hour when to send the message
REF_HOUR="17:00"
# maximum temperature
MAX_TEMP=27500
# minimum temperature
MIN_TEMP=23000

CUR_TIME=$(date +%s)
REF_TIME=$(date --date "today $REF_HOUR" +%s)

if [ "$REF_TIME" -le $(date +%s) ]; then
        REF_TIME=$(date --date "tomorrow $REF_HOUR" +%s)
fi

while [ 1=1 ]; do
        # we check the sensor number (the system allocates this randomly it seems)
        if [ -e "/sys/bus/w1/devices/$SENSOR_ID/hwmon/hwmon1" ]; then
                NUM=1
        else
                NUM=2
        fi
        NEXT_TIME=$(date +%s)
        TEMP=$(cat /sys/bus/w1/devices/$SENSOR_ID/hwmon/hwmon$NUM/temp1_input)
        if [ -z "$TEMP" ]; then
                MSG="Warning, cannot read aquarium temperature"
        elif [ "$TEMP" -lt "$MIN_TEMP" ] || [ "$TEMP" -gt "$MAX_TEMP" ]; then
                MSG="Warning, aquarium temperature out of bounds: $TEMP"
        elif [ "$CUR_TIME" -ge "$REF_TIME" ]; then
                # we set the reference to the same time tomorrow
                REF_TIME=$(date --date "tomorrow $REF_HOUR" +%s)
                MSG="Current temperature: $TEMP"
        fi
        CUR_TIME=$NEXT_TIME
        if [ ! -z "$MSG" ]; then
                echo $MSG
                echo "Do some other thing here (e.g. send an e-mail)"
                # we reset the message
                MSG=""
        fi
        DATE=$(date --rfc-3339=seconds)
        echo "Temperature at $DATE: $TEMP"
        echo -e "$DATE\t$TEMP" >> temperature.tsv
        sleep 60
done
