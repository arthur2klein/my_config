#!/bin/bash

wmo_to_icon() {
  case "$1" in
    0) echo "󰖙" ;;  # clear sky
    1|2) echo "󰖕" ;;  # partly cloudy
    3) echo "󰖐" ;;  # overcast
    45|48) echo "󰖑" ;;  # fog
    51|53|55) echo "󰖗" ;;  # drizzle
    61|63|65) echo "󰖖" ;;  # rain
    71|73|75) echo "󰼶" ;;  # snow
    80|81|82) echo "󰖗" ;;  # showers
    95|96|99) echo "󰖓" ;;  # thunderstorm
    *) echo "󰖐" ;;  # default
  esac
}

data=$(curl https://api.open-meteo.com/v1/forecast\?latitude\=43.3112\&timezone=Europe%2FParis\&longitude\=-0.3558\&current\=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code)
current_temperature="$(echo "$data" | jq -r '.current.temperature_2m')°C"
current_humidity="$(echo "$data" | jq -r '.current.relative_humidity_2m')%"
current_wind="$(echo "$data" | jq -r '.current.wind_speed_10m')km/h"
current_precipitation="$(echo "$data" | jq -r '.current.precipitation')mm"
current_weather_code=$(wmo_to_icon $(echo "$data" | jq -r '.current.weather_code'))

echo "$current_weather_code $current_temperature $current_humidity $current_precipitation $current_wind"
