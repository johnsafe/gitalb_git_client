module DRb
  require 'timeout'
  class DRbTimeout < StandardError;end
  class DRbProcessError < StandardError;end
  class ECONNRESET < StandardError;end

  class DRbMessage
    def load(soc)  # :nodoc:
      retry_times = 0
      begin
        sz = soc.read(4)        # sizeof (N)
      rescue Errno::ECONNRESET
        raise(DRb::ECONNRESET, "#{ $!.message} -- addr: #{soc.addr}", $!.backtrace)
      rescue
        raise(DRbConnError,"#{ $!.message} -- addr: #{soc.addr}", $!.backtrace)
      end

      raise(DRbConnError, 'connection closed') if sz.nil?
      raise(DRbConnError, 'premature header') if sz.size < 4
      sz = sz.unpack('N')[0]
      socket_load_limit = Settings.backend.sockect_max_limit rescue @load_limit
      raise(DRbConnError, "too large packet #{sz}") if socket_load_limit < sz
      begin
        str = soc.read(sz)
      rescue
        raise(DRbConnError, $!.message, $!.backtrace)
      end
      raise(DRbConnError, 'connection closed') if str.nil?
      raise(DRbConnError, 'premature marshal format(can\'t read)') if str.size < sz
      DRb.mutex.synchronize do
        begin
          save = Thread.current[:drb_untaint]
          Thread.current[:drb_untaint] = []
          Marshal::load(str)
        rescue NameError, ArgumentError
          DRbUnknown.new($!, str)
        ensure
          Thread.current[:drb_untaint].each do |x|
            x.untaint
          end
          Thread.current[:drb_untaint] = save
        end
      end
    end
  end

  class DRbObject
    singleton_class.send(:alias_method, :with_friend_without_retry, :with_friend)

    def self.with_friend(uri, &block) # :nodoc:
      retry_times = 0
      begin
         with_friend_without_retry(uri, &block)
      rescue DRb::ECONNRESET => e
        p e.message
        retry_times += 1
        if retry_times < 3
          p "start retry #{retry_times}"
          retry
        end
        raise e
      end
    end
  end

  class DRbTCPSocket
    alias :set_sockopt_without_keepalive :set_sockopt

    def set_sockopt(soc) # :nodoc:
      set_sockopt_without_keepalive(soc)
      soc.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
      soc.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPIDLE, 50)
      soc.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPINTVL, 10)
      soc.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPCNT, 5)
    end
  end
end
