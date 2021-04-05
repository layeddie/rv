# RV app - Nerves app to show how to switch on LED from Phoenix Liveview page

Inspiration taken from Nerves Birdapp project
https://dasky.xyz/posts/2020/08/12/an-iot-birdhouse-with-elixir-nerves-phoenix-liveview-components/
https://git.coco.study/dkhaapam/bird_app
## Hardware needed

We are using the following hardware for our birdhouse:

- Raspberry Pi 3
- Raspberry Pi Camera V2
- A simple LED connected to GPIO Pin 18 and GND
- A simple Servo motor connected to GPIO Pin 23, 5V and GND
- A DHT22 Temperature/Humidity sensor connected to GPIO Pin 4, 3.3V and GND


|       | GND | 3.3V | 5V | GPIO |
|-------|-----|------|----|------|
| DHT22 | x   | x    |    | 4    |
| Servo | x   |      | x  | 23   |
| LED   | x   |      |    | 18   |

## Install ASDF
Using ASDF to manage elixir and erlang versions using the ASDF ./tools-versions file in this project
There are many good guides for installing ASDF. This is just one example.
https://elixircasts.io/installing-elixir-with-asdf
https://github.com/asdf-vm/asdf-elixir
https://github.com/asdf-vm/asdf

## Setup Elixir
To setup your development environment on either Mac, Linux or Windows head over to the official nerves documentation.

[Installation](https://hexdocs.pm/nerves/installation.html)

## Setup node.js

We do also need node.js for our UI.

[asdf-nodejs](https://github.com/asdf-vm/asdf-nodejs)

## Create Poncho projects

https://embedded-elixir.com/post/2017-05-19-poncho-projects/

This poncho project consists of 3 separate project folders.
First create your project folder.

cd to your projects directory
```bash
mkdir rv
cd rv
```
intialise git project
```bash
git init
```
Then create 3 separate projects.

Ui - Phoenix / liveview project
```bash
mix phx.new rv_app_ui --no-ecto --live 
```
Firmware - Nerves project - main nerves project
```bash
mix nerves.new rv_app_firmware
``` 
Hardware - Nerves project - sensor component project
```bash
mix nerves.new rv_app_hardware
```




## Setup Sdcard boot label.

These changes use your project name to label the SDcard.
It changes standard BOOT-A and BOOT-B label to APPNAM±E-A or APPNAME-B.

You need to make changes to config.exs, target.exs and add copies of fwup.conf and cmdline.txt to the config folder
in your firmware project.
(Note: Manual process until I can work out how to do this with variable substitution)

Copy fwup.conf to Your config/ Directory
See Overwriting Files in the Boot Partition in https://hexdocs.pm/nerves/advanced-configuration.html

```
# Locate the fwup.conf files available in your deps directory
find deps -name fwup.conf
# Copy the one that matches your target to the config directory.
cp deps/nerves_system_rpi0/fwup.conf config/
# Also copy cmdline.txt as you'll need it below.
cp deps/nerves_system_rpi0/cmdline.txt config/
```

edit the folowing 3 lines in config/fwup.conf and change BOOT-A and BOOT-B to nerves app name.

```
fat_setlabel(${BOOT_A_PART_OFFSET}, "RVAPP-A")
fat_setlabel(${BOOT_A_PART_OFFSET}, "RVAPP-A")
fat_setlabel(${BOOT_B_PART_OFFSET}, "RVAPP-B")
```


Changes to config.exs to add new path to config/fwup.conf

```
config :nerves, :firmware, 
  rootfs_overlay: "rootfs_overlay",
  fwup_conf: "config/fwup.conf"

```

Changes to target.exs
```
# This line adds project name to iex prompt on rpi.
config :iex, default_prompt: "%prefix(%counter)_rvapp>"

```

## Setup Phoenix Project

1. Prepare your Phoenix project to build JavaScript and CSS assets:

These steps only need to be done once.
```bash
cd rv_app_ui
mix deps.get
npm install --prefix assets
```

2. Build your assets and prepare them for deployment to the firmware:

```bash
# Still in ui directory from the prior step.
# These steps need to be repeated when you change JS or CSS files.
npm install --prefix assets --production
npm run deploy --prefix assets
mix phx.digest
```

3. Change to the firmware app directory

```bash
cd ../rv_app_firmware
```

4. Specify your target and other environment variables as needed:

```bash
export MIX_TARGET=rpi3
export MIX_ENV=dev

# For the telegram bot functions
# export TELEGRAM_BOT_TOKEN=bot_token
# export TELEGRAM_CHAT_ID=chat_id
# export TELEGRAM_CHAT_URL=chat_url
#
# If you're using WiFi:
# export NERVES_NETWORK_SSID=your_wifi_name
# export NERVES_NETWORK_PSK=your_wifi_password
```

5. Set up the config

Configure the hardware pins and the ssh keys you want to use

```elixir
# bird_app/rv_app_firmware/config/target.exs

# ...
config :rv_app_hardware,
  led_pin: 18,
  dht_pin: 4,
  servo_pin: 23
# ...

# ...
keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
# ...
```

6. Get dependencies, build firmware, and burn it to a SD card:

```bash
mix deps.get
mix firmware
mix firmware.burn
```

7. Insert the SD card into your target board and connect the USB cable or otherwise power it on

8. Wait for it to finish booting (5-10 seconds)

9. Open a browser window on your host computer to http://nerves.local/ or ssh to the raspberry with `ssh nerves.local`

10. Now whenever you update the code you can also deploy the update via ssh

```bash
#create new firmware
cd rv_app_firmware
mix deps.get
mix firmware
mix upload
```


