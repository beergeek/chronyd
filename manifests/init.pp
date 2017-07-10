# Class: chronyd
# ===========================
#
# Full description of class chronyd here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'chronyd':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
# Class Chronyd
# @summary Module to manage Chronyd on RedHat 7
#
# Parameters
# @param $servers
class chronyd (
  # REQUIRED
  Array[String]               $servers,

  # From Hiera in-module-data
  Hash[String, String]        $keyfile_hash,
  String                      $package_name,
  String                      $config_path,
  String                      $template_name,
  String                      $service_name,
  Enum['absent','present']    $package_ensure,
  Optional[Hash[String, Any]] $template_hash,
  Enum['running','stopped']   $service_ensure,
  Boolean                     $service_enable,
  Boolean                     $iburst,
  String                      $stratumweight,
  String                      $drift_file,
  Boolean                     $rtcsync,
  Boolean                     $makestep,
  Integer                     $step_limit,
  Integer                     $step_number,
  String                      $ipv4_bindaddress,
  String                      $ipv6_bindaddress,
  String                      $keyfile,
  Boolean                     $noclientlog,
  Variant[Integer,Float]      $logchange_value,
  String                      $logdir,
  String                      $template_keyfile,
  String                      $keyfile_path,
  Boolean                     $replace_keyfile,
) {

  if $facts['os']['family'] != 'RedHat' and $facts['os']['release']['major'] != '7' {
    fail("This module is for RedHat 7, not ${facts['os']['family']} ${facts['os']['release']['major']}")
  }

  if $template_hash {
    $_template_hash = $template_hash
  } else {
    $_template_hash = {
      servers          => $servers,
      iburst           => $iburst,
      stratumweight    => $stratumweight,
      drift_file       => $drift_file,
      rtcsync          => $rtcsync,
      makestep         => $makestep,
      step_limit       => $step_limit,
      step_number      => $step_number,
      ipv4_bindaddress => $ipv4_bindaddress,
      ipv6_bindaddress => $ipv6_bindaddress,
      keyfile          => $keyfile,
      noclientlog      => $noclientlog,
      logchange_value  => $logchange_value,
      logdir           => $logdir,
    }
  }

  package { 'chrony_package':
    ensure => $package_ensure,
    name   => $package_name,
  }

  file { 'chrony_config':
    ensure  => 'file',
    path    => $config_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp($template_name, $_template_hash),
    require => Package['chrony_package'],
  }

  file { 'chrony_keyfile':
    ensure  => 'file',
    path    => $keyfile_path,
    replace => $replace_keyfile,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp($template_keyfile, { keyfile_hash => $keyfile_hash }),
    require => Package['chrony_package'],
  }

  service { 'chrony_service':
    ensure    => $service_ensure,
    enable    => $service_enable,
    name      => $service_name,
    subscribe => File['chrony_config'],
  }
}
