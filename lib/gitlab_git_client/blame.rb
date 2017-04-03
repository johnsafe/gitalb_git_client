module Gitlab
  module Git
    class Blame
      include Gitlab::Git::ClientMethods
      define_remote_methods :blame_array

      attr_accessor :repository, :sha, :path

      def initialize(repository, sha, path)
        @repository = repository
        @sha = sha
        @path = path
      end

      def each(&block)
        @blame_array ||= Gitlab::Git::Blame.blame_array(repository, sha, path)
        @blame_array.each(&block)
      end

    end
  end
end
