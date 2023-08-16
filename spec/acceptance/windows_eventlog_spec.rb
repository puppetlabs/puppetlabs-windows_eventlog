# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.describe 'windows_eventlog' do
  pp = <<~PP
    windows_eventlog { 'Application':
      log_path       => '%SystemRoot%\system32\winevt\Logs\Application.evtx',
      log_size       => 2048,
      max_log_policy => 'overwrite'
    }
  PP

  context 'create event log' do
    before(:all) do
      apply_manifest(pp, catch_failures: false)
    end

    describe 'Application' do
      result = Helper.instance.run_shell('Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application"')
      it { expect(result.exit_status).to eq(0) }
      it { expect(result.stdout.strip).to eq('True') }
    end
  end
end
