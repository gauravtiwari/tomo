require "forwardable"

module Tomo
  class TaskLibrary
    extend Forwardable

    def initialize(context)
      @context = context
    end

    private

    def_delegators :context, :paths, :settings
    attr_reader :context

    def die(reason)
      Runtime::TaskAbortedError.raise_with(
        reason,
        task: context.current_task,
        host: remote.host
      )
    end

    def dry_run?
      Tomo.dry_run?
    end

    def logger
      Tomo.logger
    end

    def raw(string)
      ShellBuilder.raw(string)
    end

    def remote
      context.current_remote
    end

    def require_setting(*names)
      missing = names.flatten.select { |sett| settings[sett].nil? }
      return if missing.empty?

      Runtime::SettingsRequiredError.raise_with(
        settings: missing,
        task: context.current_task
      )
    end
    alias require_settings require_setting
  end
end
