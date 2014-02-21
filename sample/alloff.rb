#!/usr/bin/env mruby

include BeagleBone

pinMode('USR0', OUTPUT)
pinMode('USR1', OUTPUT)
pinMode('USR2', OUTPUT)
pinMode('USR3', OUTPUT)
digitalWrite('USR0', 0)
digitalWrite('USR1', 0)
digitalWrite('USR2', 0)
digitalWrite('USR3', 0)
