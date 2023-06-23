module Completely
  class Installer
    attr_reader :program, :script_path

    def initialize(program:, script_path: nil)
      @program = program
      @script_path = script_path
    end

    def target_directories
      @target_directories ||= %W[
        /usr/share/bash-completion/completions
        /usr/local/etc/bash_completion.d
        #{Dir.home}/.bash_completion.d
      ]
    end

    def command
      result = root_user? ? [] : %w[sudo]
      result + %W[cp #{script_path} #{target_path}]
    end

    def command_string
      command.join ' '
    end

    def target_path
      "#{completions_path}/#{program}"
    end

    def install(force: false)
      unless completions_path
        raise 'Cannot determine system completions directory'
      end

      unless script_exist?
        raise "Cannot find script: m`#{script_path}`"
      end

      if target_exist? && !force
        raise "File exists: m`#{target_path}`"
      end

      system(*command)
    end

  private

    def target_exist?
      File.exist? target_path
    end

    def script_exist?
      File.exist? script_path
    end

    def root_user?
      Process.uid.zero?
    end

    def completions_path
      @completions_path ||= completions_path!
    end

    def completions_path!
      target_directories.each do |target|
        return target if Dir.exist? target
      end

      nil
    end
  end
end
