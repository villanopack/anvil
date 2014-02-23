require 'cocaine'
require 'anvil/analizers/rubocop'
require 'anvil/analizers/reek'

module Anvil
  class Analizer
    class << self
      def analize
        Anvil::RubocopAnalizer.run
        Anvil::ReekAnalizer.run
      end
    end
  end
end
