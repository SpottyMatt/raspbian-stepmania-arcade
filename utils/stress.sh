#!/usr/bin/env bash

# Stress tests to see if your overclocks are stable.

# requires the "stress-ng" package installed
# apt-get install stress-ng

echo "60 second CPU stress test..."
stress-ng --cpu 4 --timeout 60s --metrics-brief

echo "60 second Memory stress test..."
stress-ng --vm 2 --vm-bytes 128M --timeout 60s

