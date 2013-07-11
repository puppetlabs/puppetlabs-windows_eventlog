#Windows Event Logs module for Puppet

##Overview

Puppet module for managing windows event logs

This module is also available on the [Puppet Forge](https://forge.puppetlabs.com/liamjbennett/windows_eventlog)

[![Build
Status](https://secure.travis-ci.org/liamjbennett/puppet-windows_eventlog.png)](http://travis-ci.org/liamjbennett/puppet-windows_eventlog)
[![Dependency
Status](https://gemnasium.com/liamjbennett/puppet-windows_eventlog.png)](http://gemnasium.com/liamjbennett/puppet-windows_eventlog)

##Module Description

The purpose of this module is to manage each of the windows event logs, including the size, rotation and retention

##Usage

    windows_eventlog { 'Application':
      log_path => '%SystemRoot%\system32\winevt\Logs\Application.evtx',
      log_size => '2048',
      max_log_policy = 'overwrite'
    }

##Development
Copyright (C) 2013 Liam Bennett - <liamjbennett@gmail.com> <br/>
Distributed under the terms of the Apache 2 license - see LICENSE file for details. <br/>
Further contributions and testing reports are extremely welcome - please submit a pull request or issue on [GitHub](https://github.com/liamjbennett/puppet-windows_eventlog) <br/>

##Release Notes

__0.0.1__ <br/>
The initial version