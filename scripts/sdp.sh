#!/bin/bash

if [ "$UID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

hciconfig hci0 piscan
sdptool add SP