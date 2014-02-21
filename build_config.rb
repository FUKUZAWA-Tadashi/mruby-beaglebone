#!/usr/bin/env ruby

MRUBY_DIR = '../mruby'
ONIG_INSTALL_DIR_BASE = '/usr/local'
ONIG_INCLUDE_DIR = ONIG_INSTALL_DIR_BASE + '/include'
ONIG_LIB_DIR = ONIG_INSTALL_DIR_BASE + '/lib'

if __FILE__ == $0
  exit system(%Q[cd #{MRUBY_DIR}; MRUBY_CONFIG=#{File.expand_path __FILE__} ruby minirake #{ARGV.join(' ')}])
end


MRuby::Build.new do |conf|
  toolchain :gcc
  conf.cc do |cc|
    cc.include_paths = ["#{root}/include", ONIG_INCLUDE_DIR]
  end
  conf.linker do |linker|
    linker.library_paths = [ONIG_LIB_DIR]
  end
  conf.gembox 'default'
  conf.gem :core => 'mruby-eval'
  conf.gem :github => 'iij/mruby-io'
  conf.gem :github => 'iij/mruby-dir'
  conf.gem :github => 'iij/mruby-tempfile'
  conf.gem :github => 'iij/mruby-require'
  conf.gem :github => 'iij/mruby-process'
  conf.gem :github => 'mattn/mruby-onig-regexp'
  conf.gem File.expand_path(File.dirname(__FILE__))
end
