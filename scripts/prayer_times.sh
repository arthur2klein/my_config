#!/bin/bash

CITY="Pau"
COUNTRY="FR"
STATE="France"
METHOD="12"
TZ="Europe/Paris"

DATA=$(curl -s "https://api.aladhan.com/v1/timingsByCity/$(date +'%d-%m-%Y')?city=$CITY&country=$COUNTRY&state=$STATE&method=$METHOD&timezonestring=$(printf %s "$TZ" | jq -sRr @uri)")

get_time() {
  echo "$DATA" | jq -r ".data.timings.$1"
}

schedule_notification() {
  NAME=$1
  TIME=$2

  # Convert HH:MM to seconds from now
  TARGET=$(date -d "$TIME" +%s)
  NOW=$(date +%s)

  if [ "$TARGET" -gt "$NOW" ]; then
    DELAY=$((TARGET - NOW))
    (sleep "$DELAY"; notify-send "🕌 Prayer Time" "$NAME") &
  fi
}

schedule_notification "Fajr"    "$(get_time Fajr)"
schedule_notification "Dhuhr"   "$(get_time Dhuhr)"
schedule_notification "Asr"     "$(get_time Asr)"
schedule_notification "Maghrib" "$(get_time Maghrib)"
schedule_notification "Isha"    "$(get_time Isha)"
