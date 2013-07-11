# Define windows_eventlog
#
# This definition manages a windows event log, including the size, rotation and retention
#
# Parameters:
#   [*log_path*] - the path to the log file that you want to manage
#   [*log_size*] - the max size of the log file
#   [*max_log_policy*] - the retention policy for the log
#
# Usage:
#
#    windows_eventlog { 'Application':
#      log_path => '%SystemRoot%\system32\winevt\Logs\Application.evtx',
#      log_size => '2048',
#      max_log_policy = 'overwrite'
#    }
#
define windows_eventlog(
  $log_path,
  $log_size = '1028',
  $max_log_policy = 'overwrite'
){

  validate_string($log_path)
  validate_re($log_size, '^\d*$','The log_size argument must be a number or a string representation of a number')
  validate_re($max_log_policy, '^(overwrite|manual|archive)$','The max_log_policy argument must contain overwrite, manual or archive')

  $root_key = 'HKLM\System\CurrentControlSet\Services\Eventlog'

  registry_key { "${root_key}\\${name}":
    ensure => present
  }

  registry_value { "${root_key}\\${name}\File":
    ensure => present,
    type   => 'expand',
    data   => $log_path
  }

  registry_value { "${root_key}\\${name}\MaxSize":
    ensure => present,
    type   => 'dword',
    data   => $log_size,
  }

  case $max_log_policy {
    'overwrite': {
      registry_value { "${root_key}\\${name}\Retention":
        ensure => present,
        type   => 'dword',
        data   => '0'
      }
    }
    'manual': {
      registry_value { "${root_key}\\${name}\Retention":
        ensure => present,
        type   => 'dword',
        data   => '1'
      }
    }
    'archive': {
      registry_value { "${root_key}\\${name}\AutoBackupLogFiles":
        ensure => present,
        type   => 'dword',
        data   => '-1'
      }
    }
    default: {}
  }

}