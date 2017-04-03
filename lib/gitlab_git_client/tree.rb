require 'gitlab_git_client/encoding_helper'
require 'gitlab_git/tree'
module Gitlab
  module Git
    class Tree
      include Gitlab::Git::ClientMethods

      attr_accessor :id, :root_id, :name, :path, :type, :mode, :commit_id, :submodule_url, :repo_path
      define_remote_methods :where, :find_id_by_path, :content_by_path, :tree_contents

      def initialize(options)
        %w(id root_id name path type mode commit_id submodule_url repo_path).each do |key|
          self.send("#{key}=", options[key.to_sym])
        end
      end

      def all_blob_names(repo)
        result = []
        if self.file?
          result << self.name
        else
          entry = repo.lookup(self.id).first
          if entry[:type] == :blob
            result << entry[:name]
          elsif entry[:type] == :tree
            sub_tree = Gitlab::Git::Tree.new({id: entry[:oid], root_id: entry[:oid], repo_path: repo_path, type:entry[:type]})
            result += sub_tree.all_blob_names(repo)
          end
        end
        result
      end


      def utf8_name
        self.name
      end


      def contents(get_text_flag=true, need_text=true)
        @contents ||= Tree.tree_contents(repo, id, path, commit_id, get_text_flag, need_text)
      end

      # Find the named object in this tree's contents
      def /(file)
        Tree.content_by_path(repo, id, file, commit_id, path)
      end

      def repo
        @repo ||= Gitlab::Git::Repository.new(repo_path)
      end

      # Find only Tree objects from contents
      def trees
        contents.select { |v| v.kind_of? Tree }
      end

      # Find only Blob objects from contents
      def blobs
        contents.select { |v| v.kind_of? Gitlab::Git::Blob }
      end

      def all_blobs(id,path=nil,result=[])
        Tree.tree_contents(repo, id, path).each do |contents|
          if contents.is_a? Gitlab::Git::Blob
            result << contents
          else
            all_blobs(contents.id, contents.path, result)
          end
        end
        result
      end

    end
  end
end
