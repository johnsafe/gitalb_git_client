module Gitlab
  module Git
    class OnlineEdit
      include Gitlab::Git::ClientMethods
      define_remote_methods :drb_remote_new
      attr_reader :path

      def initialize(repo_path, ref)
        @remote_client = OnlineEdit.drb_remote_new(repo_path, [repo_path, ref])
        @path = repo_path
      end
    end
  end
end
