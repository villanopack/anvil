require 'cocaine'

module Anvil
  class RubocopAnalizer
    class << self
      def prepare
        rubocop_config_file = File.expand_path '.rubocop.yml'
        File.open(rubocop_config_file, 'a') do |f|
          f.puts 'Documentation:'
          f.puts '  Enabled: false'
          f.puts 'AllCops:'
          f.puts '  Excludes:'
          f.puts '    - vendor/bundle/**'
        end
      end

      def run
        prepare
        puts '*****************'
        puts 'STARTING RUBOCOP:'
        puts
        line = Cocaine::CommandLine.new 'rubocop', '', expected_outcodes:  [0, 1]
        puts line.run
        puts
        clean
      end

      def clean
        rubocop_config_file = File.expand_path '.rubocop.yml'
        File.delete rubocop_config_file
      end
    end
  end
end
