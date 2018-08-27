StepMania on Raspberry Pi
=========================

Scripts & instructions to turn a Raspberry Pi 3B or 3B+ running Raspian into a [StepMania](https://github.com/stepmania/stepmania) arcade console.

Under Construction
=====

For all I know this might destroy your Rasbperry Pi. Don't use any of this yet.


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

In order to get your Raspberry Pi working as an unattended StepMania console, this guide will help you achive the following things:

1. Prepare to build StepMania on a Raspberry Pi (Automatic)
2. Build and install StepMania (Automatic)
3. Configure StepMania for automatic startup (Automatic)
4. Overclock the Raspberry Pi to improve StepMania performance (Automatic)
5. Get USB sound working so the songs don't sound awful (Manual)

All of the automatic steps are driven by the `make` command-line tool.

Quick Start
=========================

1. Run `make`
2. Wait ~2 hours
3. Reboot
4. Yay, StepMania automatically starts
5. (Optional) Run `make overclock-apply` for better performance

Now head down to the [USB Audio](#usb-audio) section to get sound working.

Overclocking
=========================

_Required Reading: https://www.raspberrypi.org/documentation/configuration/config-txt/overclocking.md_

For optimal performance of this visually-demanding, timing-sensitive game, you should overclock the Raspberry Pi.

Included are two sets of overclock configuration that are slightly below the maximum stable overclock on **MY** Raspberry Pis.

They might work for yours, too. You can void your warranty and break the hardware on your Pi while overclocking.

I broke my Pi 3B by overlocking it too much, and it isn't stable anymore even with the overclocking configuration disabled.

To automatically apply incluced, probably-OK overclock settings and **VOID YOUR WARRANTY**, run

`make overclock-apply`

It will ask which Raspberry Pi you have. If you answer incorrectly you may end up installing overclock settings that will permanently ruin your Pi when you reboot.

`force_turbo` or not?
-------------------------

If your Raspberry pi will only ever be on when it is being used to run StepMania (as a true arcade console), you should set `force_turbo=1` in `/boot/config.txt`.

This will

1. Void the warranty
2. Cause the Pi to generate more heat than normal
3. Cause the Pi to consume more power than normal
4. Esnure the Pi is always running at peak performance

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


Notes
=========================

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
