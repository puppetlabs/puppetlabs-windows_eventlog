# Author::    Liam Bennett (mailto:liamjbennett@gmail.com)
# Copyright:: Copyright (c) 2014 Liam Bennett
# License::   MIT

# == Define windows_eventlog
#
# Mode that manages windows event logs, including the size, rotation and retention
#
# === Requirements/Dependencies
#
# Currently reequires the puppetlabs/stdlib module on the Puppet Forge in
# order to validate much of the the provided configuration.
#
# === Parameters
#
# [*log_path*]
# The path to the log file that you want to manage
#
# [*log_size*]
# The max size of the log file
#
# [*max_log_policy*]
# The retention policy for the log
#
# [*log_path_template*]
# A template for log_path, where "%%NAME%%" will be replaced with the log name
#
# === Examples
#
# Manage the size of the Application log:
#
#   windows_eventlog { 'Application':
#     log_path       => '%SystemRoot%\system32\winevt\Logs\Application.evtx',
#     log_size       => '2048',
#     max_log_policy => 'overwrite'
#   }
#
#
# Manage several custom event logs under C:\Logs:
#
#   windows_eventlog { ['Custom1', 'Custom2', 'Custom3']:
#     log_path_template => 'C:\Logs\%%NAME%%.evtx'
#   }
#
#
define windows_eventlog(
  $log_path          = undef,
  $log_size          = '1028',
  $max_log_policy    = 'overwrite',
  $log_path_template = "%SystemRoot%\\system32\\winevt\\Logs\\%%NAME%%.evtx"
){
  $l_log_path = $log_path? {
    undef   => regsubst( $log_path_template, '%%NAME%%', $name ),
    default => $log_path,
  }

  validate_string($l_log_path)
  validate_re($log_size, '^\d*$','The log_size argument must be a number or a string representation of a number')
  validate_re($max_log_policy, '^(overwrite|manual|archive)$','The max_log_policy argument must contain overwrite, manual or archive')
  validate_re($log_path_template, '%%NAME%%','The log_path_template must contain the string "%%NAME%%"')

  $root_key = 'HKLM\System\CurrentControlSet\Services\Eventlog'

  registry_key { "${root_key}\\${name}":
    ensure => present
  }

  registry_value { "${root_key}\\${name}\\File":
    ensure => present,
    type   => 'expand',
    data   => $l_log_path
  }

  registry_value { "${root_key}\\${name}\\MaxSize":
    ensure => present,
    type   => 'dword',
    data   => $log_size,
  }

  case $max_log_policy {
    'overwrite': {
      registry_value { "${root_key}\\${name}\\Retention":
        ensure => present,
        type   => 'dword',
        data   => '0'
      }
    }
    'manual': {
      registry_value { "${root_key}\\${name}\\Retention":
        ensure => present,
        type   => 'dword',
        data   => '1'
      }
    }
    'archive': {
      registry_value { "${root_key}\\${name}\\AutoBackupLogFiles":
        ensure => present,
        type   => 'dword',
        data   => '-1'
      }
    }
    default: {}
  }

}
