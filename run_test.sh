#!/bin/sh +x
source controll_genymotion.sh

# stop all devices
stop_all_genymotion

# clean test results
rm -rf test.json
rm -rf rerun.txt
# clean up Calabash test servers
rm -rf test_servers

# start up / wait for Genymotion simulator
get_genymotions_running "$DEVICE" || echo "Device was not found"

# determine ADB serial number
echo Using device name: $DEVICE
SERIAL="$(get_adb_serial_from_name "$DEVICE")"
# hack for 4.1.1 devices
if [ -z "$SERIAL" ]
  then
    SERIAL="$(get_adb_serial_from_name ":")"
fi
echo ADB serial of device: $SERIAL

# uninstall previous apk package
adb -s $SERIAL uninstall $PNAME

# unlock screen for 5.0.0
adb -s $SERIAL shell input keyevent 82

# run tests
ADB_DEVICE_ARG="$SERIAL" calabash-android run "$APK_PATH" --format json --out test.json --format rerun --out rerun.txt "$MORE_PARAMS"
