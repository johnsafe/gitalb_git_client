module Gitlab
  module Git
    class Cmd
      include Gitlab::Git::ClientMethods
      define_remote_methods :execute
    end
  end
end
