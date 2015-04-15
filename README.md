# GenyControl
Shell scripts for controlling Genymotion simulators

### Purpose
Starting and stopping Genymotion simulators safely and effectively from command line. This makes it ideal for continuos integration systems (i.e. Jenkins).

### How to use
Include **controll_genymotion.sh** in your bash script to access methods.
```sh
$ source controll_genymotion.sh
```

Stop all running Genymotion simulators
```sh
$ stop_all_genymotion
```

List all available Genymotion simulators
```sh
$ get_all_genymotion_names
Google Nexus 5 - 5.0.0 - API 21 - 1080x1920
Samsung Galaxy S5 - 4.4.4 - API 19 - 1080x1920
HTC Eco - 4.2.2 - API 17 - 720x1280
```

Start a certain Genymotion simulator and wait until it is booted and operational (multiple simulators may be named separated by new-line)
```sh
$ get_genymotions_running "Samsung Galaxy S5 - 4.4.4 - API 19 - 1080x1920"
$ get_genymotions_running "`get_all_genymotion_names`"
```

More commands are avaiable, look up **controll_genymotion.sh**.

**run_test.sh** contains an example script for running Calabash tests in a continuos integration system.

### Dependencies
Your **$PATH** environment variable should include directories for:
* **adb - Android Debug Bridge** - default directory: *<android-sdk>/platform-tools/*
* **player - Genymotion VM player** - default Mac directory: */Applications/Genymotion.app/Contents/MacOS*

### Known limitations
* Cannot get the boot and serial information for Android 4.1.1 devices.

### Tested on
* OS: Mac OS X 10.9.5
* Genymotion: 2.4.0
