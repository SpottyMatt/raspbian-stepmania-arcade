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

1. Run `make`.
2. Wait ~2 hours.
3. Run `make overclock-apply`
4. Reboot
5. Yay, StepMania automatically starts.

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
| over_voltage_sdram_c | 0       | 3          |
| over_voltage_sdram_i | 0       | 3          |
| over_voltage_sdram_p | 0       | 3          |


### Raspberry Pi 3B+

| Setting              | Default | Max Stable |
| -------------------- | ------- | ---------- |
| arm_freq             | 1400    |            |
| core_freq            | 400     |            |
| sdram_freq           | 500     |            |
| over_voltage         | 0       |            |
| over_voltage_sdram   | 0       |            |
| over_voltage_sdram_c | 0       |            |
| over_voltage_sdram_i | 0       |            |
| over_voltage_sdram_p | 0       |            |

USB Audio
=========================
