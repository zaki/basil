require 'forwardable'

# mixins
require 'basil/chat_history'
require 'basil/logging'
require 'basil/utils'

# base classes
require 'basil/server'

# classes
require 'basil/cli'
require 'basil/config'
require 'basil/dispatch'
require 'basil/email'
require 'basil/lock'
require 'basil/message'
require 'basil/plugin'
require 'basil/skype'
require 'basil/storage'

module Basil
  class << self
    include Logging

    extend Forwardable
    def_delegators Plugin, :respond_to,
                           :watch_for,
                           :check_email

    def run(argv)
      if argv.include?('--debug')
        Logger.level = ::Logger::DEBUG
      end

      if argv.include?('--cli')
        Config.server = Cli.new
      end

      Config.server.start

    rescue => ex
      fatal "#{ex}"

      ex.backtrace.map do |line|
        debug "#{line}"
      end

      exit 1
    end
  end
end
