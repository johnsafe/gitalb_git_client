# Gitlab::Git::Repository is a wrapper around native Rugged::Repository object
module Gitlab
  module Git
    class Repository
      attr_accessor :path
      # route_path : path_with_namespace
      include Gitlab::Git::ClientMethods

      define_remote_methods :init, :import, :drb_remote_rename, :drb_remote_delete, :drb_remote_change_owner, :drb_remote_fork, :drb_remote_new, :update_head

      def self.rename(name_with_path, new_name_with_path)
        self.drb_remote_rename(name_with_path, [name_with_path, new_name_with_path])
      end

      def self.delete(name_with_path)
        self.drb_remote_delete(name_with_path, [name_with_path])
      end

      def self.change_owner(name_with_path, new_owner_name)
        repo_name = name_with_path.split('/').last
        new_name_with_path = "#{new_owner_name}/#{repo_name}"
        self.drb_remote_change_owner(name_with_path, [name_with_path, new_owner_name])
      end

      def self.fork(name_with_path, source_name_with_path)
        self.drb_remote_fork(source_name_with_path, [name_with_path, source_name_with_path])
      end

      # path_with_namespace like: 'john/repo_test.git'
      def initialize(path_with_namespace)
        @path = path_with_namespace
        @remote_client = Repository.drb_remote_new(path_with_namespace, [path_with_namespace])
      end
    end
  end
end
