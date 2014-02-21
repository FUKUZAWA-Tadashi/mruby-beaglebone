INSTALL
=======


## fix git certificates problem
```
# opkg install ca-certificates
# vi ~/.gitconfig
# cat ~/.gitconfig
[http]
    sslVerify = true
    sslCAinfo = /etc/ssl/certs/ca-certificates.crt
```

## prepare mruby
```
# opkg update
# opkg install ruby
# opkg install bison
# git clone git://github.com/mruby/mruby.git
# cd mruby
# make test
# cd ..
```

## compile and install oniguruma
```
# wget http://www.geocities.jp/kosako3/oniguruma/archive/onig-5.9.5.tar.gz
# tar zxf onig-5.9.5.tar.gz
# cd onig-5.9.5
# ./configure
# make
# make install
# cd ..
# vi /etc/ld.so.conf
# cat /etc/ld.so.conf
/lib
/usr/lib
/usr/local/lib
# ldconfig
```
If you want to use other regexp library, edit mruby-beaglebone/build_config.rb appropriately.

## compile and install mruby with mruby-beaglebone
```
# git clone git://github.com/FUKUZAWA-Tadashi/mruby-beaglebone.git
# mruby-beaglebone/build_install.sh
```

## Done.
Now you can use /usr/local/bin/mruby .
Try scripts under mruby-beaglebone/sample/ directory.
```
# mruby mruby-beaglebone/sample/allon.rb
# mruby mruby-beaglebone/sample/alloff.rb
# mruby mruby-beaglebone/sample/knight.rb
# mruby mruby-beaglebone/sample/led_default.rb
```
Enjoy!
