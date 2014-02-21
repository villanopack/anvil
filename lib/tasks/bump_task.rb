require 'anvil/task'
require 'anvil/config'
require 'anvil/versioner'

module Projects
  class BumpTask < Anvil::Task
    attr_reader :project, :options

    description 'Bump a new version of a project'
    parser do
      on('-s', '--source BRANCH') do |value|
        options[:source] = value
      end

      on('t', '--term TERM') do |value|
        options[:term] = value
      end
    end

    def initialize(project, options = {})
      @project = project
      @options = options
    end

    def task
      source = source_branch(project)
      target = target_branch(project, source)

      on_project(project) do
        git = Git.open(Dir.pwd)
        update_branch(git, source)
        # check_status?
        merge(git, source, target) unless source == target
        change_version
        changelog
        # update gemfile.lock if gemspec?
        # git commit
      end
    end

    def on_project(project)
      Dir.chdir(Anvil::Config.base_projects_path + "/#{project}") do
        yield
      end
    end

    def merge(git, source, target)
      update_branch(git, target)
      git.merge(source, nil)
    end

    def update_branch(git, branch)
      git.checkout(branch)
      git.pull('origin', branch)
    end

    def change_version
      File.open('VERSION', 'a+') do |file|
        versioner = Anvil::Versioner.new(file.read)
        file.truncate
        term = options[:term] || 'minor'
        new_version = versioner.send("#{term}!")

        file.write(new_version.to_s)
      end
    end

    def changelog
      filename = detect_changelog_file
      actual_changelog = File.read(filename)
      version = File.read('VERSION')
      date = Time.new.strftime('%d %B %Y %H:%M')
      history = git_changelog_command

      require 'byebug';byebug
      File.open(filename, 'w+') do |file|
        file << changelog_output(version, date, history)
        file << actual_changelog
      end
    end

    def changelog_output(version, date, history)
      output = ""
      output << version
      output << "\n----------\n"
      output << "release: #{date}\n"
      output << "\n #{history}\n\n"
      output
    end

    def detect_changelog_file
      Dir['CHANGELOG*'].first # TODO: raise exception if nil
    end

    def git_changelog_command
      %x{git --no-pager log --merges --pretty=format:'- %b' `git describe --abbrev=0 --tags`..}
    end

    def target_branch(project, source)
      flow = flow_for_project(project)
      flow[flow.index(source) + 1]
    end

    def source_branch(project)
      @options[:source] || flow_for_project(project).first
    end

    def flow_for_project(project)
      project_config(project).flow || ['master']
    end

    def project_config(project)
      projects_config && projects_config.send(project.to_sym) ||
        projects_config
    end

    def projects_config
      Anvil::Config.projects
    end
  end
end
