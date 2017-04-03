module Gitlab
  module Git
    class Branch < Ref
      def utf8_name
        self.name
      end

      def commit(repo)
        #Gitlab::Git::Commit.find(repo,self.name)
	      repo.commit(self.target)
      end
    end
  end
end
