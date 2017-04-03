require 'gitlab_git_client/encoding_helper'
require 'gitlab_git/commit'
module Gitlab
  module Git
    class Commit
      include Gitlab::Git::ClientMethods

      undef_method :raw_commit
      attr_accessor :repo_path, :tree_oid
      define_remote_methods :drb_remote_where, :find, :last, :last_for_path, :between_rpc, :diff_from_parent_rpc, :to_patch

      class << self
        def where(options)
          repo = options[:repo]
          self.drb_remote_where(repo.path, [options])
        end

        def find_all(repo, options = {})
          repo.find_commits(options)
        end

        def decorate_rpc(commit, repo_path, ref = nil)
          Commit.new(commit, repo_path,  ref)
        end

      end


      def initialize(raw_commit, repo_path=nil, head = nil)
        raise "Nil as raw commit passed" unless raw_commit
        # raise "Nil as repo_path passed" unless repo_path

        if raw_commit.is_a?(Hash)
          init_from_hash(raw_commit)
        elsif raw_commit.class.to_s == 'Rugged::Commit' || raw_commit.is_a?(DRb::DRbObject)
          init_from_rugged(raw_commit)
        else
          raise Rugged::InvalidError.new "Invalid raw commit type: #{raw_commit.class}"
        end

        @head = head
        @repo_path = raw_commit.is_a?(Hash) ? raw_commit[:repo_path] : repo_path
      end


      # def drb_name
      #   if repo_path || head
      #     "commit_with_path_head_#{Digest::SHA1.hexdigest("#{sha}_#{@repo_path}_#{@head}")}"
      #   else
      #     "commit_#{sha}"
      #   end
      # end

      def repo
        return @repo unless @repo.nil?
        @repo = Gitlab::Git::Repository.new(repo_path)
      end

      def to_diff
        patch = to_patch_rpc
        # discard lines before the diff
        lines = patch.split("\n")
        while !lines.first.start_with?("diff --git") do
          lines.shift
        end
        lines.pop if lines.last =~ /^[\d.]+$/ # Git version
        lines.pop if lines.last == "-- " # end of diff
        lines.join("\n")
      end

      def raw_commit
        repo.rugged.lookup(id)
      end

      def to_patch_rpc
        return @patch if @patch
        @patch = Commit.to_patch(repo, id)
      end

      def diffs_rpc(options = {})
        Commit.diff_from_parent_rpc(repo, self.id, options)
      end

      def parents
        parents_rpc
      end

      def parents_rpc
        @parent_ids.map { |parent_id| Commit.find(repo, parent_id) }
      end

      def tree
        tree_rpc
      end

      def tree_rpc
        Client.remote_commit_tree(repo_path, self)
      end

      def stats
        Client.remote_commit_stats_new(repo_path, self)
      end

      def refs_rpc
        repo.refs_hash_rpc[id]
      end

      def remote_ref_names
        ref_names_rpc
      end

      def ref_names_rpc
        refs_rpc.map{|ref| ref.name.sub(%r{^refs/(heads|remotes|tags)/}, "") }
      end

      #add
      def utf8_message
        encode! self.message
      end

      # return a hash
      def author
        {:name=>self.author_name, :email=>self.author_email, :time=>self.authored_date, :utf8_email=>encode!(self.author_email), :utf8_name=>encode!(self.author_name)}
      end

      def committer
        {:name=>self.committer_name, :email=>self.committer_email, :time=>self.committed_date, :utf8_email=>encode!(self.committer_email), :utf8_name=>encode!(self.committer_name)}
      end

      def self.list_from_string(repo, text)
        lines = text.split("\n")
        commits = []
        while !lines.empty?
          id = lines.shift.split.last
          # tree = lines.shift.split.last
          parents = []
          parents << lines.shift.split.last while lines.first =~ /^parent/
          author_line = lines.shift
          author_line << lines.shift if lines[0] !~ /^committer /
          # author, authored_date = self.actor(author_line)
          committer_line = lines.shift
          committer_line << lines.shift if lines[0] && lines[0] != '' && lines[0] !~ /^encoding/
          # committer, committed_date = self.actor(committer_line)
          # not doing anything with this yet, but it's sometimes there
          encoding = lines.shift.split.last if lines.first =~ /^encoding/
          lines.shift
          message_lines = []
          message_lines << lines.shift[4..-1] while lines.first =~ /^ {4}/
          lines.shift while lines.first && lines.first.empty?
          raw = Gitlab::Git::Commit.find(repo, id)
          commits << Gitlab::Git::Commit.new(raw, repo.path)
        end
        commits
      end

      def rugged_tree
        entry_hash={}
        @entries.each { |e| entry_hash[e[:name]] = e }
        entry_hash
      end

      private

      def init_from_hash(hash)
        raw_commit = hash.symbolize_keys

        serialize_keys.each do |key|
          send("#{key}=", raw_commit[key])
        end
      end

      def init_from_rugged(commit)
        @id = commit.oid
        @message = commit.message
        @authored_date = commit.author[:time]
        @committed_date = commit.committer[:time]
        @author_name = commit.author[:name]
        @author_email = commit.author[:email]
        @committer_name = commit.committer[:name]
        @committer_email = commit.committer[:email]
        @parent_ids = []
        ps = commit.parents
        ps.count.times do |i|
          @parent_ids << ps[i].oid
        end
        @tree_oid = commit.tree.oid
        @entries = commit.tree.entries
      end

      def serialize_keys
        SERIALIZE_KEYS << :tree_oid
      end

    end
  end
end
