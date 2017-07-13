# Class: chronyd
# ===========================
#
# Full description of class chronyd here.
#
# Parameters
# ----------
#
# @param servers [Array[String]] An array of the IP addresses or hostnames of NTP peers. No default.
#
# @param keyfile_hash [Hash[String, String]] A hash of key IDs and keys. Default value: {}
# @param package_name [String] The name of the Chrony package. Default value: 'chrony'
# @param config_path [String] The path and name of the Chrony config file. Default value: '/etc/chrony.conf'
# @param template_name [String] The name of the template for chrony.conf file. Default value: 'chronyd/chrony.conf.epp'
# @param service_name [String] The name of the Chrony service. Default value: 'chronyd'
# @param package_ensure [Enum['absent','present']] Ensure value for package. Default value: 'present'
# @param template_hash [Optional[Hash[String,Any]]] A hash of options for the chrony.conf. This is for a custom template only. Default value: {}
# @param service_ensure [Enum['running','stopped']] Determine if the service is running or stopped. Default value: 'running'
# @param service_enable [Boolean] Determine if the service is enabled or not. Default value: true
# @param iburst [Boolean] Determine if iburst is enabled or not. Default value: true
# @param stratumweight [Variant[Float,Integer]] The stratumweight value in seconds. Default value: 0.001
# @param drift_file [String] Name and path of the drift file. Default value: '/var/lib/chrony/drift'
# @param rtcsync [Boolean] Boolean to determine if RTC Sync is enabled. Default value: true
# @param makestep [Boolean] Boolean value to determine if makestep is enabled. Default value: true
# @param step_threshold [Variant[Integer,Float] The threshold value that will trigger a step change in time. Default value: 0.1
# @param step_number [Integer] The number of steps to apply change over if time difference is larger than $step_threshold. Default value: 10
# @param ipv4_bindaddress [String] IP V4 address to bind. Default value: '127.0.0.1'
# @param ipv6_bindaddress [String] IP V6 address to bind. Default value: '::1'
# @param keyfile [String] Name and path of the Chrony key file. Default value: '/etc/chrony.keys'
# @param noclientlog [Boolean] Value to determine if client access is logged. Default value: true
# @param logchange_value [Variant[Integer,Float]] Threshold value that will cause a syslog message if time difference is greater than. Default value: 0.1
# @param logdir [String] Name and path of log directory. Default value: '/var/log/chrony'
# @param template_keyfile [String] Name and path of the EPP template for the keyfile. Default value: 'chronyd/keyfile.epp'
# @param keyfile_path [String] Name and path of the keyfile. Default value: '/etc/chrony.keys'
# @param replace_keyfile [Boolean] Determine if the keyfile is overriden if it exists. Default value: true
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
  Variant[Integer,Float]      $stratumweight,
  String                      $drift_file,
  Boolean                     $rtcsync,
  Boolean                     $makestep,
  Variant[Integer,Float]      $step_threshold,
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
