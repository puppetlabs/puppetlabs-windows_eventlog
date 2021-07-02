# @summary Manage Windows Event Logs
#
# Manage windows event logs including the size, rotation and retention
#
# @param log_path
#   The path to the log file that you want to manage
#
# @param log_size
#   The max size of the log file
#
# @param max_log_policy
#   The retention policy for the log
#
# @param log_path_template
#   A template for log_path, where "%%NAME%%" will be replaced with the log name
#
# @param root_key
#   The root path of the registry key of which prepends this defined type
#
# @example Manage the size of the Application log:
#   windows_eventlog { 'Application':
#     log_path       => '%SystemRoot%\system32\winevt\Logs\Application.evtx',
#     log_size       => '2048',
#     max_log_policy => 'overwrite'
#   }
#
# @example Manage several custom event logs under C:\Logs:
#   windows_eventlog { ['Custom1', 'Custom2', 'Custom3']:
#     log_path_template => 'C:\Logs\%%NAME%%.evtx'
#   }
#
define windows_eventlog (
  # This is not Stdlib::Absolutepath because the tests use a path begining with
  # '%SystemRoot%' which does not match
  Optional[String[1]] $log_path = undef,
  Integer $log_size = 1028,
  Enum['overwrite', 'manual', 'archive']  $max_log_policy = 'overwrite',
  String[1] $log_path_template = '%SystemRoot%\system32\winevt\Logs\%%NAME%%.evtx',
  String[1] $root_key = 'HKLM\System\CurrentControlSet\Services\Eventlog',
) {
  $_log_path = $log_path? {
    undef   => regsubst( $log_path_template, '%%NAME%%', $name ),
    default => $log_path,
  }

  $retention = $max_log_policy ? {
    'overwrite' => '0',
    'manual'    => '1',
    'archive'   => '-1',
  }

  $auto_backup_log_files = $max_log_policy ? {
    'overwrite' => '0',
    'manual'    => '0',
    'archive'   => '-1',
  }

  registry_key { "${root_key}\\${name}":
    ensure => present,
  }

  registry_value { "${root_key}\\${name}\\File":
    ensure => present,
    type   => 'expand',
    data   => $_log_path,
  }

  registry_value { "${root_key}\\${name}\\MaxSize":
    ensure => present,
    type   => 'dword',
    data   => $log_size,
  }

  registry_value { "${root_key}\\${name}\\Retention":
    ensure => present,
    type   => 'dword',
    data   => $retention,
  }

  registry_value { "${root_key}\\${name}\\AutoBackupLogFiles":
    ensure => present,
    type   => 'dword',
    data   => $auto_backup_log_files,
  }
}
