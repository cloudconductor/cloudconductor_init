require 'logger'
require 'yaml'

class ActionRunner
  class << self
    def execute(role, event)
      if event == 'configure'
        pre_configure
        sleep 30
      end
      patterns = pattern_dirs('platform') + pattern_dirs('optional')
      patterns.each do |pattern_dir|
        send_event(pattern_dir, role, event)
      end
    end

    private

    def pre_configure
      bin_dir = File.join(root_dir, 'bin')
      if system("cd #{bin_dir}; /bin/sh ./configure.sh")
        logger.info('pre-configure executed successfully.')
      else
        logger.error("pre-configure failed. configure.sh returns #{$?}.")
        exit 1
      end
    end

    def send_event(pattern_dir, role, event)
      if system("cd #{pattern_dir}; /bin/sh ./event_handler.sh #{role} #{event}")
        logger.info("#{event} event executed on #{File.basename(pattern_dir)} successfully")
      else
        logger.error("#{event} event failed on #{File.basename(pattern_dir)}. returns #{$?}.")
        exit 1
      end
    end

    def pattern_dirs(type)
      patterns_root_dir = File.join(root_dir, 'patterns')
      Dir.glob("#{patterns_root_dir}/*/").inject([]) do |pattern_dirs, pattern_dir|
        metadata_file = File.join(pattern_dir, 'metadata.yml')
        next unless File.exist?(metadata_file)
        pattern_type = YAML.load_file(metadata_file)['type']
        pattern_dirs << pattern_dir if pattern_type == type
        pattern_dirs
      end
    end

    def root_dir
      '/opt/cloudconductor'
    end

    def logger
      @logger ||= init_logger
    end

    def init_logger
      log_file = File.join(root_dir, 'logs', 'event-handler.log')
      logger = Logger.new(log_file)
      logger.formatter = proc do |severity, datetime, _progname, message|
        "[#{datetime.strftime('%Y-%m-%dT%H:%M:%S')}] #{severity}: #{message}\n"
      end
      logger
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  role = ARGV[0]
  event = ARGV[1]
  ActionRunner.execute(role, event)
end
