module Gitlab
  module Git
    class Tag < Ref
      include EncodingHelper
      attr_reader :message, :created_at

      def initialize(name, target, message = nil, rugged_ref=nil, created_at=nil)
        super(name, target)
        @message = encode! message
        @created_at = created_at
      end

      def utf8_name
        self.name
      end

      def utf8_message
        message
      end

      def commit(repo)
        #Gitlab::Git::Commit.find(repo(repo_path), (self.target.is_a?(String) ? self.target : self.name))
	repo.commit(self.target||self.name)
      end

      # def raw_tag(repo_path)
      #   @rugged_tag ||= repo(repo_path).rugged.tags.find { |tag| tag.name.eql?(self.name) }
      # end

      def repo(repo_path)
        @repo ||= Gitlab::Git::Repository.new(repo_path)
      end

    end
  end
end
