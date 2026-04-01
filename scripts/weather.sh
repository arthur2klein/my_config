#!/bin/bash

wmo_translation() {
  case "$1" in
    0) echo "󰖙";; # Clear sky
    1) echo "";; # Mainly clear
    2) echo "";; # Partly cloudy
    3) echo "";; # Overcast
    45) echo "󰖑";; # Fog
    48)	echo "";; # Depositing rime fog
    51) echo "󰸊";; # Light drizzle
    53) echo "󰖌";; # Moderate drizzle
    55) echo "";; # Dense drizzle
    56) echo "󰸊";; # Light freezing drizzle
    57) echo "";; # Dense freezing drizzle
    61) echo "󰖗";; # Slight rain
    63) echo "";; # Moderate rain
    65)	echo "";; # Heavy rain
    66) echo "󰖗";; # Light freezing rain
    67)	echo "";; # Heavy freezing rain
    71) echo "󰖘";; # Slight snow fall
    73) echo "󰼶";; # Moderate snow fall
    75) echo "";; # Heavy snow fall
    77)	echo "";; # Snow grains
    80) echo "";; # Slight rain showers
    81) echo "";; # Moderate rain showers
    82) echo "";; # Violent rain showers
    85) echo "";; # Slight snow showers
    86) echo "";; # Heavy snow showers
    95)	echo "";; # Thunderstorm
    96) echo "";; # Thunderstorm with slight hail
    99) echo "";; # Thunderstorm with heavy hail
    *) echo "" ;; # Unknown
  esac
}

data=$(curl https://api.open-meteo.com/v1/forecast\?latitude\=43.3112\&timezone=Europe%2FParis\&longitude\=-0.3558\&current\=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation_probability,weather_code)
current_temperature="$(echo "$data" | jq -r '.current.temperature_2m')°C"
current_humidity="$(echo "$data" | jq -r '.current.relative_humidity_2m')"
current_wind="$(echo "$data" | jq -r '.current.wind_speed_10m')km/h"
current_weather_code=$(wmo_translation $(echo "$data" | jq -r '.current.weather_code'))

echo "$current_weather_code $current_temperature $current_humidity $current_wind"
