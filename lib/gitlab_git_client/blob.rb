require 'linguist'
require 'gitlab_git_client/encoding_helper'
require 'gitlab_git/blob'
module Gitlab
  module Git
    class Blob
      include Gitlab::Git::ClientMethods

      attr_accessor :over_flow_flag, :is_binary
      define_remote_methods :find, :raw, :commit, :blame, :find_entry_by_path

      def self.remove(repository, options)
        self.commit(repository, options,:remove)
      end

      def drb_name
        "blob_#{self.id}"
      end

      def text?
        !binary?
      end

      def dir?
        false
      end

      def type
        :blob
      end

      def binary?
        return @is_binary unless @is_binary.nil?
        data_binary?(data)
      end

      def utf8_name
        encode! self.name
      end

      def utf8_data
        encode! self.data
      end

      def file?
        true
      end

      def large?
        return @over_flow_flag unless @over_flow_flag.nil?
        size.to_i > MEGABYTE
      end
    end
  end
end
