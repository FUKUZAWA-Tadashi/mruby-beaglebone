#!/usr/bin/env mruby

#
# connect LED to the pin
#
pin = "P8_13"


include BeagleBone

pinMode(pin, OUTPUT)

val = 0.0
velo = 0.0003
freq = 5000

5.times do
  while val < 1.0
    analogWrite(pin, val, freq)
    val += velo
  end
  val = 1.0
  while val > 0.0
    analogWrite(pin, val, freq)
    val -= velo
  end
  val = 0
end

analogWrite(pin, 0, freq)


