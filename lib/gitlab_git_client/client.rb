module Gitlab
  module Git
    class ClientError < StandardError;end
    class Client
      ALL_SERVICE_HOSTS = Settings.backend.repo_hosts

      include Gitlab::Git::ClientMethods
      define_remote_methods :remote_commit_tree, :remote_commit_stats_new, :remote_merge_repo_add_fetch_source!

      
      class << self
        def start_client
          return if $services

          #start local drb_server
	        $services = []
          local_ip = Socket.ip_address_list.find {|a| a.ipv4? && !a.ipv4_loopback?}.ip_address
          DRb.start_service "druby://#{local_ip}:0"

          #connect remote drb server
          ALL_SERVICE_HOSTS.each do |host|
            $services << DRbObject.new_with_uri("druby://#{host}:9001")
          end


        end

        def get_service(path)
          # $services[(0...ALL_SERVICE_HOSTS.size).to_a.sample]
          services = []
          if path.is_a?(String)
            rege = path.match(/(([^\/]*)\/[^\/]*)\.git$/)
            namespace = rege ? rege[1].sub(/\.wiki$/, "") : nil

            ip = if rege && rege[2] == "snippets"
                   service_snippet_ip(namespace)
                 elsif rege && !namespace.nil?
                   service_ip(namespace)
                 else
                   raise "Can't find server"
                 end
            index = ALL_SERVICE_HOSTS.index(ip)||0
            services << $services[index]
          end

          services << $services[ALL_SERVICE_HOSTS.index(Settings.backend.default_host)] if services.empty?
          services.first
        end

        def redis_server
          @server ||= Redis.new(:host => Settings.redis.route_host, :port => Settings.redis.route_port)
        end

        def service_ip(dir)
          ip = redis_server.hget('repo_ipmap', dir)
          ip = Settings.backend.default_host unless ip
          ip
        end

        def service_snippet_ip(dir)
          ip = redis_server.hget('snippet_ipmap', dir)
          ip = Settings.backend.default_host unless ip
          ip
        end

        def service_user_ip(name)
          ip = redis_server.hget('user_ipmap', name)
          ip = Settings.backend.default_host unless ip
          ip
        end
      end
    end
  end
end
