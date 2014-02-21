#!/usr/bin/env mruby


# $ mruby knight.rb
# Ctrl-C

# $ mruby knight.rb &
# $ kill [pid]


include BeagleBone

leds = ['USR0', 'USR1', 'USR2', 'USR3']
leds.each {|x| pinMode(x, OUTPUT)}

x = 0
dir = 1
pid = callInterval(0.1) do
  n = x + dir
  if n >= 3
    dir = -1
  elsif n <= 0
    dir = 1
  end
  digitalWrite(leds[x], LOW)
  digitalWrite(leds[n], HIGH)
  x = n
end

puts "pid = #{pid}"
Process::waitpid(pid)
leds.each {|x| digitalWrite(x, LOW)}

