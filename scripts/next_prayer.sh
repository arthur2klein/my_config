#!/bin/bash

CITY="Pau"
COUNTRY="FR"
STATE="France"
METHOD="12"
TZ="Europe/Paris"

DATA=$(curl -s "https://api.aladhan.com/v1/timingsByCity/$(date +'%d-%m-%Y')?city=$CITY&country=$COUNTRY&state=$STATE&method=$METHOD&timezonestring=$(printf %s "$TZ" | jq -sRr @uri)")

now=$(date -d "-5 minutes" +%s)

get_time() {
  echo "$DATA" | jq -r ".data.timings.$1"
}

# Ordered prayers
prayers=("Fajr" "Dhuhr" "Asr" "Maghrib" "Isha")

for prayer in "${prayers[@]}"; do
  time_of_prayer=$(get_time "$prayer")
  time_of_prayer_s=$(date -d "$time_of_prayer" +%s)
  if [ "$time_of_prayer_s" -ge "$now" ]; then
    echo "🕌 $prayer $time_of_prayer"
    exit 0
  fi
done

# If all prayers passed → show tomorrow Fajr
fajr=$(get_time "Fajr")
echo "🕌 Fajr $fajr"
