StepMania on Raspberry Pi
=========================

Scripts & instructions to turn a Raspberry Pi 3B or 3B+ running Raspian into a [StepMania](https://github.com/stepmania/stepmania) arcade console.

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Overclocking](#overclocking)
4. [USB Audio](#usb-audio)
5. [Notes](#notes)

Prerequisites
=========================

**You** must provide the following:

1. A supported Raspberry Pi model
	1. 3B
	2. 3B+
2. An installed & working [Raspian](https://www.raspberrypi.org/downloads/raspbian/) operating system, Stretch (v9) or later.
3. A [USB sound card that works out-of-the-box with the Raspberry Pi](https://learn.adafruit.com/usb-audio-cards-with-a-raspberry-pi?view=all)

In order to get your Raspberry Pi working as an unattended StepMania console, this guide will help you achive the following things:

1. Prepare to build StepMania on a Raspberry Pi
2. Build and install StepMania
3. Configure StepMania for automatic startup
4. Overclock the Raspberry Pi to improve StepMania performance
5. Enable USB Sound by default

All of the steps are driven by the `make` command-line tool.

Quick Start
=========================

1. Run `make`
2. Wait ~2 hours
3. Reboot
4. Yay, StepMania automatically starts
5. (Optional) Run `make overclock-apply` for better performance

Now head down to the [USB Audio](#usb-audio) section if sound isn't coming out of your USB sound card.

Overclocking
=========================

_Required Reading: https://www.raspberrypi.org/documentation/configuration/config-txt/overclocking.md_

For optimal performance of this visually-demanding, timing-sensitive game, you should overclock the Raspberry Pi.

Included are two sets of overclock configuration that are slightly below the maximum stable overclock on **MY** Raspberry Pis.

They might work for yours, too. You can void your warranty and break the hardware on your Pi while overclocking.

I broke my Pi 3B by overlocking it too much, and it isn't stable anymore even with the overclocking configuration disabled.

To automatically apply included, probably-OK overclock settings and **VOID YOUR WARRANTY**, run

`make overclock-apply`

It will ask which Raspberry Pi you have. If you answer incorrectly you may end up installing overclock settings that will permanently ruin your Pi when you reboot.

`force_turbo` or not?
-------------------------

If your Raspberry pi will only ever be on when it is being used to run StepMania (as a true arcade console), you should set `force_turbo=1` in `/boot/config.txt`.

This will

1. Void the warranty
2. Cause the Pi to generate more heat than normal
3. Cause the Pi to consume more power than normal
4. Ensure the Pi is always running at peak performance

This is the default when using `make overclock-apply`.

If you just want to play StepMania on your Pi but it will frequently be turned on and _not_ running anything resource-intensive, you should _not_ set `force_turbo=1`.

You can run `make no-turbo` or edit `/boot/config.txt` by hand to remove any `force_turbo` lines.

Manual Overclocking
-------------------------

In case you want to twiddle the overclock settings by hand, here's a helpful chart.
The "Max stable" settings **WILL VARY BETWEEN DIFFERENT BOARDS** and are what I found were "just below" unstable on _my_ Pis.

### Raspberry Pi 3B

| Setting              | Default | Max Stable |
| -------------------- | ------- | ---------- |
| arm_freq             | 1200    | 1400       |
| core_freq            | 400     | 500        |
| sdram_freq           | 450     | 550        |
| over_voltage         | 0       | 3          |
| over_voltage_sdram   | 0       | 3          |

### Raspberry Pi 3B+

| Setting              | Default | Max Stable |
| -------------------- | ------- | ---------- |
| arm_freq             | 1400    | 1500       |
| core_freq            | 400     | 600        |
| sdram_freq           | 500     | 700        |
| over_voltage         | 0       | 3          |
| over_voltage_sdram   | 0       | 3          |

USB Audio
=========================

The Raspberry Pi uses its built-in headphone jack or the HDMI cable as the default sound output device.
The hardware that drives these is not very capable. StepMania's songs will sound scratch.
To have good sound quality, you must use a USB sound card.

Getting this USB sound card working, and then working _as the default sound device_ can be hard.
Do yourself a favor and buy one that is known to work out-of-the-box with the Raspberry Pi.
Adafruit [sells one](https://www.adafruit.com/product/1475), or you can trust reviews on some other marketplace like Amazon.

Get USB Sound Working
-------------------------

Plug in your sound card. Use one or some combination of the following to try to activate it:

1. Raspian GUI
2. `raspi-config`
3. `alsamixer`

At this point it's just a "how to get USB sound card working on Linux" problem.

* `dmesg` will show messages when you connect a USB device. Run `dmesg -w` and then plug the device in to watch it try to connect.
* `lsusb` will show connected USB devices.
* `aplay -l` will show recognized sound devices.

Make USB Sound the Default
-------------------------

This was probably already done by the [`usb-audio-by-default.conf`](system-prep/usb-audio-by-default.conf) modprobe configuration being installed by the `system-prep` target.
The key was to explicitly order all the devices, even the ones _you don't want and/or have blacklisted_, to ensure that USB is always "card 0".

If you find that your Pi does _not_ default to putting sound out through the USB sound card... you're on your own.

This is a great resource to start: https://raspberrypi.stackexchange.com/a/80075

Notes
=========================

1. [Make Targets](#make-targets)
2. [Performance Benchmarks](#performance-benchmarks)
3. [Building for Other Raspberry Pi Models](#building-for-other-raspberry-pi-models)

Make Targets
-------------------------

The intended use of this `Makefile` is

1. `make`
2. `make overclock-apply`

If you _want_ to do some of the tasks individually, they are:

### `make system-prep`

1. Install build dependencies for StepMania
2. Prepare StepMania installation directory
3. Configure `/boot/config.txt` with non-overclock settings (including enabling OpenGL)

### `make stepmania-prep`

1. Patch StepMania to support building on ARM
2. Run `cmake` to prepare StepMania to build

### `make stepmania-build`

Build StepMania

### `make stepmania-install`

1. `make install` StepMania to `/usr/local`
2. Set up StepMania to start automatically on login.
3. Set some StepMania `Preferences.ini` settings.

### `make overclock-apply`

Allow applying probably-OK (but warranty-voiding) overclock settings to the Raspberry Pi, for improved StepMania performance.

### `make no-turbo`

Remove the `force_turbo=1` setting from `/boot/config.txt`.

Use this if you expect the Pi to be turned on and NOT running StepMania for significant periods of its life.

Performance
-------------------------

### Rasbperry Pi 3B

| Screen Resolution | Texture Size | Overclocked? | Framerate |
| ----------------- | ------------ | ------------ | --------- |
| 1280 x 720        | 512          | Yes          | 45        |

### Rasbperry Pi 3B+

| Screen Resolution | Texture Size | Overclocked? | Framerate |
| ----------------- | ------------ | ------------ | --------- |
| 1680 x 1050       | 512          | No           | 32        |
| 1680 x 1050       | 512          | Yes          | 37        |

Building for Other Raspberry Pi Models
-------------------------

If you look at [`raspi-3b-arm.patch`](stepmania-build/raspi-3b-arm.patch), you'll see there are two variables that really matter for building StepMania:

1. `ARM_CPU`
2. `ARM_FPU`

Those are set in the `Makefile` to the correct values for the Raspberry Pi 3B/3B+.

See this excellent gist: [GCC compiler optimization for ARM-based systems](https://gist.github.com/fm4dd/c663217935dc17f0fc73c9c81b0aa845) for more information on compiling with GCC on Raspberry Pi.

In particular, it's got tables of the `ARM_CPU` and `ARM_FPU` values for other Raspberry Pi models.
Who knows, they might work! The regular 3B was just powerful enough to run StepMania acceptably; older models may struggle to perform.

Edit your `Makefile` and give it a try!
