module Gitlab
  module Git
    class MergeRepo
      include Gitlab::Git::ClientMethods

      define_remote_methods :commits_and_diffs, :save_patch, :merge_conflict_files, :conflict_merge!, :automerge!, :cache, :drb_remote_get_patch, :merge_to!, :commits_check

      def self.get_patch(repo_path, patch_name)
        self.drb_remote_get_patch(repo_path, [patch_name])
      end

      def self.add_fetch_source!(repo_path, source_repo_url, source_name, fetch_name)
        Gitlab::Git::Client.remote_merge_repo_add_fetch_source!(repo_path, source_repo_url, source_name, fetch_name)
      end
    end
  end
end
