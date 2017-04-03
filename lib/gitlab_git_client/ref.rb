require 'gitlab_git_client/encoding_helper'
require 'gitlab_git/ref'
module Gitlab
  module Git
    class Ref
      def utf8_name
        self.name
      end
    end
  end
end
