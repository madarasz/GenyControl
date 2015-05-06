#!/bin/sh

# seconds between each tries when waiting for device
WAITTIME=3
# maximum attempts when waiting for device
MAXWAITS=20
# if you want colors on output
if [[ $COLORS == "yes" ]]
then
  red='\x1B[0;31m'
  green='\x1B[0;32m'
  yellow='\x1B[0;33m'
  nocolor='\x1B[0m'
fi

# shuts down all Genymotion simulators, DO NOT USE if you have other VMs running as well
stop_all_genymotion() {
  echo "${yellow}*** Stopping all Genymotion simulators.${nocolor}"

  # send poweroff command to VMs
  MACHINES="$(get_running_genymotion_names)"
  if [ -z "$MACHINES" ]
    then
      echo "No VirtualBox Machines are running"
    else
      while read -r line; do echo "Shutting down: $line"; VBoxManage controlvm "$line" poweroff; done <<< "$MACHINES"
  fi

  # close remaining Genymotion processes
  ps aux | grep -i 'player --vm-name' | awk '{print $2}' | xargs kill || echo "No simulators were running."

  # stop ADB to get rid of stuck devices
  adb kill-server
}

# returns the list of names of runnning Genymotion simulators
get_running_genymotion_names() {
  echo "$(VBoxManage list runningvms | cut -d'"' -f2)"
}

# returns the list of names of all available Genymotion simulators
get_all_genymotion_names() {
  echo "$(VBoxManage list vms | cut -d'"' -f2)"
}

# returns the list of device IDs of running Genymotion simulators
get_running_genymotion_ids() {
  echo "$(VBoxManage list runningvms | sed 's/.*{\([^{]*\)\}.*/\1/g')"
}

# returns adb serial number from device name, only returns first match
get_adb_serial_from_name() {
  DNAME="$1"
  echo "$(adb devices -l | grep "${DNAME//[-. ]/_}" | head -1 | cut -d\  -f1)"
}

# returns device ID from device name, only returns first match
get_id_from_name() {
  echo "$(VBoxManage list vms | grep "$1" | head -1 | sed 's/.*{\([^{]*\)\}.*/\1/g')"
}

# starts a Genymotion simulator. parameter is device name. DON'T FORGET to put VM player on $PATH!
start_genymotion() {
  player --vm-name $1 &
}

# makes Genymotion simulators available. starts them and waits for them if they are not available.
# parameter is devices names seperated by new line (\n)
get_genymotions_running() {

  # starting them up if they are not running yet
  while read -r line
    do
      echo "*** Checking device: $line"
      if ! is_booted "$line"
        then
          DEVICEID="$(get_id_from_name "$line")"
          echo "*** Device ID is: $DEVICEID"
          start_genymotion "$DEVICEID"
          wait_for_boot "$line"
          sleep 5 # just in case
        else
          echo "${green}*** Device was already running: $line ${nocolor}"
      fi
  done <<< "$1"
}

# checks if a Genymotion simulator is running with the requested adb serial number
is_adb_running() {
  if ! adb devices | grep -q "$1"
    then
      return 1
  fi
}

# checks if a Genymotion simulator is booted with the requested device name
is_booted() {

  SERIAL="$(get_adb_serial_from_name "$1")"
  if [ -z "$SERIAL" ]
    then
      # no such device exists (maybe VM is just starting up)
      return 1
  fi

  BOOTED="$(adb -s $SERIAL shell getprop init.svc.bootanim)"
  if [[ ! "$BOOTED" == *"stopped"* ]]
    then
      #device is still booting
      return 1
  fi
}

# wait until Genymotion simulator is booted with requested device name
wait_for_boot() {
  i=0
  until is_booted "$1"
    do
      # check if we waited long enough to give up
      if [ "$i" -eq "$MAXWAITS" ]
        then
        echo "${red}*** Giving up on device: $1 ${nocolor}"
        return 1
      fi

      echo "${yellow}... Waiting for device to boot: $1 ${nocolor}"
      sleep $WAITTIME
      ((i++))
  done

  echo "${green}*** Device is operational: $1 ${nocolor}"
}

# check that Genymotion VM player is on path
check_VM_player() {
  echo "Checking Genymotion VM player."
  player
  if [ "$?" -eq "127" ]
    then
      echo "ERROR: Put Genymotion VM player on your \$PATH !!!"
      return 1
    else
      return 0
  fi
}
