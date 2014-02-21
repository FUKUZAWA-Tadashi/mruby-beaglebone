mruby-beaglebone
================

## Note

'mruby-beaglebone' is a mruby gem for controlling [BeagleBone](http://elinux.org/Beagleboard:BeagleBoneBlack).
This software is modified from ['bonescript'](https://github.com/beagleboard/bonescript).
Part of Digital and Analog I/O are implemented, Serial and I2C are not yet.

I have tested on BeagleBone Black Rev.A6, Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone-2013.06.20 .



## API

### Digital and Analog I/O

* getPinMode(pin)
* pinMode(pin, direction, mux = 7, pullup = nil, slew = 'fast')
* digitalRead(pin)
* digitalWrite(pin, value)
* analogRead(pin)
* analogWrite(pin, value, freq)

### like javascript timer function

* callTimeout(time) { .... }
* callInterval(time) { .... }

### constants

* INPUT = 'input'
* OUTPUT = 'output'
* INPUT_PULLUP = 'in_pullup'
* HIGH = 1
* LOW = 0


## TODO

* implement Serial
* implement I2C
* callTimeout() and callInterval() use linux process, but it may better use libuv.


## License

Same as original [bonescript license](https://github.com/beagleboard/bonescript/blob/master/LICENSE) below.


Copyright (c) 2011 Jason Kridner <jdk@ti.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

