#!/usr/bin/env mruby

include BeagleBone

['heartbeat', 'mmc0', 'cpu0', 'mmc1'].each_with_index do |t, i|
  digitalWrite("USR#{i}", LOW)
  writeTextFile("/sys/class/leds/beaglebone:green:usr#{i}/trigger", t)
end

