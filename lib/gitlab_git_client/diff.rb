require 'gitlab_git/diff'
module Gitlab
  module Git
    class Diff
      class TimeoutError < StandardError; end
      include EncodingHelper
      include Gitlab::Git::ClientMethods

      # Diff properties
      attr_accessor :old_path, :new_path, :a_mode, :b_mode, :diff

      # Stats properties
      attr_accessor  :new_file, :renamed_file, :deleted_file

      define_remote_methods :between, :between_with_size

      def utf8_diff
        encode! self.diff
      end

      def deleted_file?
        @deleted_file
      end

      def new_file?
        @new_file
      end

      def has_diff
        !diff.nil?
      end
    end
  end
end
