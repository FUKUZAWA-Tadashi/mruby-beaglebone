#!/usr/bin/env mruby

include BeagleBone

leds = ['USR0', 'USR1', 'USR2', 'USR3']
leds.each {|x| pinMode(x, OUTPUT)}

callTimeout(1) do
  leds.each {|x| digitalWrite(x, HIGH)}
end

callTimeout(2) do
  digitalWrite(leds[0], LOW)
  digitalWrite(leds[1], LOW)
end

callTimeout(3) do
  digitalWrite(leds[0], HIGH)
  digitalWrite(leds[1], HIGH)
  digitalWrite(leds[2], LOW)
  digitalWrite(leds[3], LOW)
end

pid = callTimeout(4) do
  leds.each {|x| digitalWrite(x, LOW)}
end

Process.waitpid pid
