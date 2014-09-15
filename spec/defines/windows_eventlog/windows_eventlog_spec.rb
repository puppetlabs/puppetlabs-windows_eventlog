require 'spec_helper'

describe 'windows_eventlog', :type => :define do

  describe 'log with incorrect log_path' do
    let :title do 'Application' end
    let :params do
      { :log_path => true, :log_size => '1028', :max_log_policy => 'overwrite' }
    end

    it do
      expect {
        should contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\File')
      }.to raise_error(Puppet::Error)
    end
  end

  describe 'log with incorrect log_size' do
    let :title do 'Application' end
    let :params do
      { :log_path => '%SystemRoot%\system32\winevt\Logs\Application.evtx', :log_size => 'aaa', :max_log_policy => 'overwrite' }
    end

    it do
      expect {
        should contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\File')
      }.to raise_error(Puppet::Error) {|e| expect(e.to_s).to match 'The log_size argument must be a number or a string representation of a number' }
    end
  end

  describe 'log with incorrect max_log_policy' do
    let :title do 'Application' end
    let :params do
      { :log_path => '%SystemRoot%\system32\winevt\Logs\Application.evtx', :log_size => '1028', :max_log_policy => 'nothing' }
    end

    it do
      expect {
        should contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\File')
      }.to raise_error(Puppet::Error) {|e| expect(e.to_s).to match 'The max_log_policy argument must contain overwrite, manual or archive' }
    end
  end

  describe 'log with manual max_log_policy' do
    let :title do 'Application' end
    let :params do
      { :log_path => '%SystemRoot%\system32\winevt\Logs\Application.evtx', :log_size => '1028', :max_log_policy => 'manual' }
    end

    it { should contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\Retention').with(
      'ensure' => 'present',
      'type' => 'dword',
      'data' => '1'
    )}
  end

  describe 'log with overwrite max_log_policy' do
    let :title do 'Application' end
    let :params do
      { :log_path => '%SystemRoot%\system32\winevt\Logs\Application.evtx', :log_size => '1028', :max_log_policy => 'overwrite' }
    end

    it { should contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\Retention').with(
      'ensure' => 'present',
      'type' => 'dword',
      'data' => '0'
    )}
  end

  describe 'log with archive max_log_policy' do
    let :title do 'Application' end
    let :params do
      { :log_path => '%SystemRoot%\system32\winevt\Logs\Application.evtx', :log_size => '1028', :max_log_policy => 'archive' }
    end

    it { should contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\AutoBackupLogFiles').with(
      'ensure' => 'present',
      'type' => 'dword',
      'data' => '-1'
    )}
  end

  describe 'log default data' do
    let :title do 'Application' end
    let :params do
      { :log_path => '%SystemRoot%\system32\winevt\Logs\Application.evtx', :log_size => '2222', :max_log_policy => 'manual' }
    end

    it { should contain_registry_key('HKLM\System\CurrentControlSet\Services\Eventlog\Application').with(
      'ensure' => 'present'
    )}

    it { should contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\File').with(
      'ensure' => 'present',
      'type'   => 'expand',
      'data'   => '%SystemRoot%\system32\winevt\Logs\Application.evtx'
    )}

    it { should contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\MaxSize').with(
      'ensure' => 'present',
      'type'   => 'dword',
      'data'   => '2222'
    )}
  end
end
