#!/usr/bin/env bash

menu() {
  rofi -dmenu -p "$1"
}

ACTION=$(printf "unpair\npair\nconnect\ndisconnect" | menu "Bluetooth action")

[ -z "$ACTION" ] && exit 0

case "$ACTION" in

  pair)
    bluetoothctl --timeout 3 scan on >/dev/null
    DEVICE=$(bluetoothctl devices |
      sed 's/^Device //' |
      menu "Pair device" |
      awk '{print $1}')

    [ -n "$DEVICE" ] && {
      bluetoothctl trust "$DEVICE"
      bluetoothctl pair "$DEVICE"
    }
    ;;

  unpair)
    DEVICE=$(bluetoothctl devices |
      sed 's/^Device //' |
      menu "Pair device" |
      awk '{print $1}')

    [ -n "$DEVICE" ] && {
      bluetoothctl cancel-pairing "$DEVICE"
      bluetoothctl untrust "$DEVICE"
    }
    ;;

  connect)
    DEVICE=$(bluetoothctl devices |
      sed 's/^Device //' |
      menu "Connect device" |
      awk '{print $1}')

    [ -n "$DEVICE" ] && bluetoothctl connect "$DEVICE"
    ;;

  disconnect)
    DEVICE=$(bluetoothctl devices Connected |
      sed 's/^Device //' |
      menu "Disconnect device" |
      awk '{print $1}')

    [ -n "$DEVICE" ] && bluetoothctl disconnect "$DEVICE"
    ;;

  *)
    exit 0
    ;;
esac

