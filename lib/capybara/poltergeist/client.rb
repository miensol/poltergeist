module Capybara::Poltergeist
  class Client
    PHANTOMJS_SCRIPT  = File.expand_path('../client/compiled/main.js', __FILE__)
    PHANTOMJS_VERSION = '1.6.0'
    PHANTOMJS_NAME    = 'phantomjs'

    def self.start(*args)
      client = new(*args)
      client.start
      client
    end

    attr_reader :pid, :port, :path, :inspector, :width, :height

    def initialize(port, inspector = nil, path = nil, width = 1024, height = 768)
      @port      = port
      @inspector = inspector
      @path      = path || PHANTOMJS_NAME
      @width     = width
      @height    = height

      pid = Process.pid
      at_exit { stop if Process.pid == pid }
    end

    def start
      check_phantomjs_version
      @pid = Spawn.spawn(*command)
    end

    def stop
      if pid
        begin
		  if RUBY_PLATFORM =~ /mingw/ 
			Process.kill('KILL', pid)
		  else
            Process.kill('TERM', pid)
		  end
          Process.wait(pid)
        rescue Errno::ESRCH, Errno::ECHILD
          # Zed's dead, baby
        end

        @pid = nil
      end
    end

    def restart
      stop
      start
    end

    def command
      @command ||= begin
        parts = [path]

        if inspector
          parts << "--remote-debugger-port=#{inspector.port}"
          parts << "--remote-debugger-autorun=yes"
        end

        parts << PHANTOMJS_SCRIPT
        parts << port
        parts << width
        parts << height
        parts
      end
    end

    private

    def check_phantomjs_version
      return if @phantomjs_version_checked

      version = `#{path} --version`.chomp

      if $? != 0
        raise PhantomJSFailed.new($?)
      elsif version < PHANTOMJS_VERSION
        raise PhantomJSTooOld.new(version)
      end

      @phantomjs_version_checked = true
    end
  end
end
