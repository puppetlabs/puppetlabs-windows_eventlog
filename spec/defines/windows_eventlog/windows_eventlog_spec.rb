# frozen_string_literal: true

require 'spec_helper'

describe 'windows_eventlog', type: :define do
  describe 'log with incorrect log_path' do
    let(:title) { 'Application' }
    let :params do
      { log_path: true, log_size: 1028, max_log_policy: 'overwrite' }
    end

    it do
      expect {
        expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\File')
      }.to raise_error(Puppet::Error)
    end
  end

  describe 'log with incorrect log_size' do
    let(:title) { 'Application' }
    let :params do
      { log_path: '%SystemRoot%\system32\winevt\Logs\Application.evtx', log_size: 'aaa', max_log_policy: 'overwrite' }
    end

    it do
      expect {
        expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\File')
      }.to raise_error(Puppet::PreformattedError)
    end
  end

  describe 'log with incorrect max_log_policy' do
    let(:title) { 'Application' }
    let :params do
      { log_path: '%SystemRoot%\system32\winevt\Logs\Application.evtx', log_size: 1028, max_log_policy: 'nothing' }
    end

    it do
      expect {
        expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\File')
      }.to raise_error(Puppet::PreformattedError)
    end
  end

  describe 'log with manual max_log_policy' do
    let(:title) { 'Application' }
    let :params do
      { log_path: '%SystemRoot%\system32\winevt\Logs\Application.evtx', log_size: 1028, max_log_policy: 'manual' }
    end

    it do
      expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\Retention').with(
        'ensure' => 'present',
        'type' => 'dword',
        'data' => '1',
      )
    end
  end

  describe 'log with overwrite max_log_policy' do
    let(:title) { 'Application' }
    let :params do
      { log_path: '%SystemRoot%\system32\winevt\Logs\Application.evtx', log_size: 1028, max_log_policy: 'overwrite' }
    end

    it do
      expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\Retention').with(
        'ensure' => 'present',
        'type' => 'dword',
        'data' => '0',
      )
    end
  end

  describe 'log with archive max_log_policy' do
    let(:title) { 'Application' }
    let :params do
      { log_path: '%SystemRoot%\system32\winevt\Logs\Application.evtx', log_size: 1028, max_log_policy: 'archive' }
    end

    it do
      expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\AutoBackupLogFiles').with(
        'ensure' => 'present',
        'type' => 'dword',
        'data' => '-1',
      )
    end
  end

  describe 'log default data' do
    let(:title) { 'Application' }
    let :params do
      { log_path: '%SystemRoot%\system32\winevt\Logs\Application.evtx', log_size: 2222, max_log_policy: 'manual' }
    end

    it do
      expect(subject).to contain_registry_key('HKLM\System\CurrentControlSet\Services\Eventlog\Application').with(
        'ensure' => 'present',
      )
    end

    it do
      expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\File').with(
        'ensure' => 'present',
        'type' => 'expand',
        'data' => '%SystemRoot%\system32\winevt\Logs\Application.evtx',
      )
    end

    it do
      expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Application\MaxSize').with(
        'ensure' => 'present',
        'type' => 'dword',
        'data' => '2222',
      )
    end
  end

  describe 'log without a log_path' do
    let(:title) { 'Something' }
    let :params do
      { log_size: 1028, max_log_policy: 'overwrite' }
    end

    it 'infers the log_path using $name' do
      expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Something\File').with(
        'ensure' => 'present',
        'type' => 'expand',
        'data' => '%SystemRoot%\system32\winevt\Logs\Something.evtx',
      )
    end
  end

  describe 'log with a custom log_path_template and without log_path' do
    let(:title) { 'Custom1' }
    let :params do
      { :log_size => 1028, :max_log_policy => 'overwrite', 'log_path_template' => 'C:\Logs\%%NAME%%' }
    end

    it 'infers the log_path using $log_path_template and $name' do
      expect(subject).to contain_registry_value('HKLM\System\CurrentControlSet\Services\Eventlog\Custom1\File').with(
        'ensure' => 'present',
        'type' => 'expand',
        'data' => 'C:\Logs\Custom1',
      )
    end
  end
end
