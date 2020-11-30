#!/bin/bash

if [ `pgrep bluetooth_server` > 0 ]; then
    echo "Killing button_process"
    kill `pgrep bluetooth_server`
fi
