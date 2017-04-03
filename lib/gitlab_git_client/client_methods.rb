module Gitlab
  module Git
    module ClientMethods
      def method_missing(action, *args, &block)
        super unless @remote_client
        @remote_client.send(action, *args, &block)
      end

      def self.included(c) 
        def c.define_remote_methods(*args)
          args.each do |method_name|
            self.define_singleton_method(method_name) do |*method_args, &method_block|
              # p "------------- method_name: " +  "     " + method_name.to_s
              # p "************** methods_args: " + method_args.class.name + "     " + method_args.to_s
              #  method_name drb_remote_new
              # method_args  ["u010131870/1111111.git", ["u010131870/1111111.git"]]"
              # method_block

              #设计思想是 drb_remote 调用时，第一个参数是已存在的仓库地址，这样才能找到路由
              path = method_args[0]
              #当第一个参数包含path属性时，只有第一个参数是repo对象， 在commit.where时出现
              path = path.path if path.respond_to?(:path)
              raise ArgumentError.new unless path.to_s.match(/[^\/]+\/[^\/]+/)
              action = method_name
              params = method_args
              if method_name.to_s.start_with?("drb_remote_")
                 action = method_name.to_s.sub(/^drb_remote_/, "").to_sym
                 params = method_args[1]
              end


              service = Gitlab::Git::Client.get_service(path)
              raise Gitlab::Git::ClientError.new("Can`t find a server for this repo") if service.nil?
              class_with_action = (self.name == "Gitlab::Git::Client" ? action :  "#{self.name}.#{action}")
              service.send(class_with_action, *params, &method_block)
            end
          end
        end

      end
      
      
    end
  end
end
