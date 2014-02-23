require 'fileutils'
require 'anvil/task'
require 'anvil/analizer'

class AnalizeTask < Anvil::Task
  description 'Analize your code'

  attr_reader :directory, :options

  def initialize(directory = nil, options = {})
    @directory = directory
    @options = options
  end

  def task
    Anvil::Analizer.analize
  end

end
