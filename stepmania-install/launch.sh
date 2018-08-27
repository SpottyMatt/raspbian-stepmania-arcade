#!/usr/bin/env bash

# hide the cursor
unclutter -display :0 -noevents -grab &

# start StepMania
/usr/local/stepmania-5.2/stepmania

# kill the thing that's hiding the cursor
pkill unclutter
