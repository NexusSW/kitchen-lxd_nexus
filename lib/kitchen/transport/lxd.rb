require 'kitchen/transport/base'
require 'kitchen/driver/lxd_version'
require 'shellwords'
require 'fileutils'

module Kitchen
  module Transport
    class Lxd < Kitchen::Transport::Base
      kitchen_transport_api_version 2

      plugin_version Kitchen::Driver::LXD_VERSION

      def initialize(config = {})
        super
        @cache = {}
      end

      def connection(state)
        begin
          @cache[state[:container_name]] ||= Connection.new nx_transport(state), config.to_hash.merge(state)
        end.tap { |conn| yield conn if block_given? }
      end

      def nx_transport(state)
        instance.driver.nx_transport state
      end

      class Connection < Transport::Base::Connection
        def initialize(transport, options)
          super options
          @nx_transport = transport
        end

        attr_reader :nx_transport

        def execute(command)
          return unless command && !command.empty?

          # There are some bash-isms coming from chef_zero (in particular, multiple_converge)
          # so let's wrap it
          command = command.shelljoin if command.is_a? Array
          command = ['bash', '-c', command]
          res = nx_transport.execute(command, capture: true) do |stdout_chunk, stderr_chunk|
            logger << stdout_chunk if stdout_chunk
            logger << stderr_chunk if stderr_chunk
          end
          res.error!
        end

        def upload(locals, remote)
          nx_transport.execute("mkdir -p #{remote}").error!
          [locals].flatten.each do |local|
            nx_transport.upload_file local, File.join(remote, File.basename(local)) if File.file? local
            if File.directory? local
              debug "Transferring folder (#{local}) to remote: #{remote}"
              nx_transport.upload_folder local, remote
            end
          end
        end

        def download(remotes, local)
          FileUtils.mkdir_p local unless Dir.exist? local
          [remotes].flatten.each do |remote|
            nx_transport.download_folder remote.to_s, local, auto_detect: true
          end
        end

        # TODO: wrap this in bash -c '' if on windows with WSL and ENV['TERM'] is not set - and accept a :disable_wsl transport config option
        def login_command
          args = [options[:container_name]]
          if options[:config][:server]
            args <<= options[:config][:server]
            args <<= options[:config][:port].to_s
            args <<= options[:config][:rest_options][:verify_ssl].to_s if options[:config][:rest_options].key?(:verify_ssl)
          end
          LoginCommand.new 'lxc-shell', args
        end
      end
    end
  end
end
