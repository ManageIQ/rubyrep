$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rubygems'
require 'yaml'

gem 'activerecord', '>= 3.0.5'
require 'active_record'

require 'rubyrep/version'
require 'rubyrep/configuration'
require 'rubyrep/initializer'
require 'rubyrep/session'
require 'rubyrep/connection_extenders/connection_extenders'
require 'rubyrep/table_scan_helper'
require 'rubyrep/table_scan'
require 'rubyrep/type_casting_cursor'
require 'rubyrep/proxy_cursor'
require 'rubyrep/proxy_block_cursor'
require 'rubyrep/proxy_row_cursor'
require 'rubyrep/direct_table_scan'
require 'rubyrep/proxied_table_scan'
require 'rubyrep/database_proxy'
require 'rubyrep/command_runner'
require 'rubyrep/proxy_runner'
require 'rubyrep/proxy_connection'
require 'rubyrep/table_spec_resolver'
require 'rubyrep/scan_report_printers/scan_report_printers'
require 'rubyrep/scan_report_printers/scan_summary_reporter'
require 'rubyrep/scan_report_printers/scan_detail_reporter'
require 'rubyrep/scan_progress_printers/scan_progress_printers'
require 'rubyrep/scan_progress_printers/progress_bar'
require 'rubyrep/base_runner'
require 'rubyrep/scan_runner'
require 'rubyrep/committers/committers'
require 'rubyrep/committers/buffered_committer'
require 'rubyrep/log_helper'
require 'rubyrep/sync_helper'
require 'rubyrep/table_sorter'
require 'rubyrep/table_sync'
require 'rubyrep/syncers/syncers'
require 'rubyrep/syncers/two_way_syncer'
require 'rubyrep/syncers/one_way_syncer'
require 'rubyrep/sync_runner'
require 'rubyrep/trigger_mode_switcher'
require 'rubyrep/logged_change_loader'
require 'rubyrep/logged_change'
require 'rubyrep/replication_difference'
require 'rubyrep/replication_helper'
require 'rubyrep/replicators/replicators'
require 'rubyrep/replicators/two_way_replicator'
require 'rubyrep/replicators/one_way_replicator'
require 'rubyrep/task_sweeper'
require 'rubyrep/replication_run'
require 'rubyrep/replication_runner'
require 'rubyrep/prepare_replication_runner'
require 'rubyrep/uninstall_runner'
require 'rubyrep/uninstall_tables_runner'
require 'rubyrep/generate_runner'
require 'rubyrep/noisy_connection'

Dir["#{File.dirname(__FILE__)}/rubyrep/connection_extenders/*.rb"].each do |extender|
  # jdbc_extender.rb is only loaded if we are running on jruby
  require extender unless extender =~ /jdbc/ and not RUBY_PLATFORM =~ /java/
end

require 'rubyrep/replication_initializer'
require 'rubyrep/replication_extenders/replication_extenders'

Dir["#{File.dirname(__FILE__)}/rubyrep/replication_extenders/*.rb"].each do |extender|
  require extender
end

module RR
  def self.heartbeat(file)
    require 'fileutils'
    FileUtils.touch(file) unless file.nil?
  end

  # Run the block for +t+ seconds, and raise an exception if it doesn't
  # complete in time.
  #
  # Unlike stdlib timeout, this avoids cross-thread raises. But unlike a
  # raw Thread.new { .. }.join(t), it also avoids leaving unattended
  # threads running in the background, by killing them upon timeout.
  def self.limited_execute(t)
    thread = Thread.new { yield }
    value = thread.join(t)

    if thread.status
      thread.kill
      raise "Execution timed out (exceeded #{t}s)"
    else
      value
    end
  end
end
