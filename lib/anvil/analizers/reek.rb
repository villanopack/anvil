require 'cocaine'

module Anvil
  class ReekAnalizer
    class << self
      def prepare
        reek_config_file = File.expand_path 'sanitize.reek'
        File.open(reek_config_file, 'a') do |f|
          f.puts 'IrresponsibleModule:'
          f.puts '  enabled: false'
          f.puts 'UtilityFunction:'
          f.puts '  enabled: false'
        end
      end

      def dirs_to_analize
        dirs = Dir.glob('*').select { |f| File.directory? f }
        dirs.delete 'vendor'
        dirs
      end

      def run
        prepare
        directories = dirs_to_analize.join(' ')
        puts '*****************'
        puts 'STARTING REEK:'
        puts
        line = Cocaine::CommandLine.new 'reek', directories, expected_outcodes: [0, 1, 2]
        puts line.run
        puts ' '
        clean
      end

      def clean
        reek_config_file = File.expand_path 'sanitize.reek'
        File.delete reek_config_file
      end
    end
  end
end
