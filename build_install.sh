#!/bin/sh

MRUBY_DIR="../mruby"
MRUBY_INSTALL_DIR="/usr/local/bin"

cd `dirname $0`
ruby ./build_config.rb && install -v ${MRUBY_DIR}/bin/mruby ${MRUBY_DIR}/bin/mirb ${MRUBY_DIR}/bin/mrbc ${MRUBY_INSTALL_DIR}/

