# RvAppUi

# RV app - Nerves app to show how to switch on LED from Phoenix Liveview page

This is project is in progress - not complet

DONE:
1. Create poncho project and setup sdcard naming.
2. Tested nerves rv_app_firmare project running on rpi0. - 05/04/21

TODO:

3. Test LED turns on and off from rpi iex prompt.
4. Add Led config and LED Component to hardware / firmware and ui projects.
5. Add LED on/off button to Phoenix / Liveview ui project. 
6. Test LED turns on and off from liveview page.
 - In progress

Inspiration taken from Nerves Birdapp project

https://dasky.xyz/posts/2020/08/12/an-iot-birdhouse-with-elixir-nerves-phoenix-liveview-components/

https://git.coco.study/dkhaapam/bird_app

https://hexdocs.pm/nerves/user-interfaces.html#phoenix-web-interfaces
## Hardware needed

We are using the following hardware for our rv LED:

- Raspberry Pi 0
- A simple LED connected to GPIO Pin 18 and GND

|       | GND | 3.3V | 5V | GPIO |
|-------|-----|------|----|------|
| LED   | x   |      |    | 18   |

## Install ASDF
Use ASDF to manage elixir and erlang versions. 
Using the ASDF ./tools-versions file in this project
There are many good guides for installing ASDF. This is just one example.

[Installing Elixir with ASDF](https://elixircasts.io/installing-elixir-with-asdf)

https://github.com/asdf-vm/asdf-elixir

https://github.com/asdf-vm/asdf

## Setup Elixir
To setup your development environment on either Mac, Linux or Windows head over to the official nerves documentation.

[Elixir Installation](https://hexdocs.pm/nerves/installation.html)

Test your elixir installation
```
$ elixir -v
Erlang/OTP 23 [erts-11.1.1] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Elixir 1.11.3 (compiled with Erlang/OTP 23)
```
Check nerves versions in the firmware folder
```
~/projects/learn/rv/rv_app_firmware> mix nerves.info
Nerves:           1.7.5
Nerves Bootstrap: 1.10.2
Elixir:           1.11.3
|nerves_bootstrap| Info End
```
Check Phoenix / liveview version
```
~/projects/learn/rv/rv_app_ui> mix phx.new --version
Phoenix v1.5.7
```
## Setup node.js

We do also need node.js for our UI.

[asdf-nodejs](https://github.com/asdf-vm/asdf-nodejs)

## Create Main Poncho projects

[Poncho projects](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)

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
Add ASDF .tool-versions file to rv project folder
```
touch .tool-versions
```
edit .tool-versions and add elixir 1.11.3-otp-23 or whatever version you are using.

Then create 3 separate projects under the rv directory

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
This is what the projects rv folder looks like..
```
ls -ltra
..
.tool-versions 
rv_app_firmware
.elixir_ls
rv_app_hardware
.
rv_app_ui
.git
```
## Setup Sdcard boot label in rv_app_firmware project.

These changes use your project name to label the SDcard.

It changes standard BOOT-A and BOOT-B label to APPNAME-A or APPNAME-B.

You need to make changes to config.exs, target.exs and add copies of fwup.conf and cmdline.txt to the config folder
in your firmware project.

(Note: This is the manual process until I can work out how to do this with variable substitution)

Copy fwup.conf to Your config/ Directory

See Overwriting Files in the Boot Partition in https://hexdocs.pm/nerves/advanced-configuration.html

Locate the fwup.conf files available in your deps directory
```
cd rv_app_firmware
find deps -name fwup.conf
```
Copy the one that matches your target to the config directory.
```
cp deps/nerves_system_rpi0/fwup.conf config/
```
Also copy cmdline.txt as you'll need it below.
```
cp deps/nerves_system_rpi0/cmdline.txt config/
```

edit the folowing 3 lines in config/fwup.conf and change BOOT-A and BOOT-B to nerves app name.

```bash
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

This line adds project name to iex prompt on rpi.
```
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
export MIX_TARGET=rpi0
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

Nerves CLI should look like this..
```
$ ssh nerves.local
Interactive Elixir (1.11.3) - press Ctrl+C to exit (type h() ENTER for help)
████▄▖    ▐███
█▌  ▀▜█▙▄▖  ▐█
█▌ ▐█▄▖▝▀█▌ ▐█   N  E  R  V  E  S
█▌   ▝▀█▙▄▖ ▐█
███▌    ▀▜████

Toolshed imported. Run h(Toolshed) for more info.
RingLogger is collecting log messages from Elixir and Linux. To see the
messages, either attach the current IEx session to the logger:

  RingLogger.attach

or print the next messages in the log:

  RingLogger.next
  Application: rvapp
  Host developer source location:
  Github repo url:

iex(1)_rv_app> 
```
Your SDCARD should be labelled RVAPP-A or RVAPP-B when viewing in Finder(MACOS)


## Test LED turns on and off from rpi iex prompt

The firmware part of the application can now be tested in isolation from the ui.

```bash
iex(1)_rv_app> alias Circuits.GPIO
Circuits.GPIO
iex(2)_rv_app> GPIO.open(18, :output)
{:ok, #Reference<0.1090687248.268828682.162864>}
iex(3)_rv_app> {:ok, led} = v 2
{:ok, #Reference<0.1090687248.268828682.162864>}
iex(4)_rv_app> led
#Reference<0.1090687248.268828682.162864>
iex(5)_rv_app> GPIO.write led, 1
:ok
iex(6)_rv_app> GPIO.write led, 0
:ok
iex(7)_rv_app> GPIO.write led, 1
:ok
iex(8)_rv_app>
```


------------------------------------------------------------------------

Test LED turns on and off from rpi iex prompt

TODO: 05/04/21

3. Test LED turns on and off from rpi iex prompt.
4. Add Led config and LED Component to hardware / firmware and ui projects.
5. Add LED on/off button to Phoenix / Liveview ui project. 
6. Test LED turns on and off from liveview page.
 - In progress

