require "spec_helper"

describe Gitlab::Git::Repository do
  include EncodingHelper
  let(:patch_path) { File.join(SeedRepo::Repo::DEFAULT_PATCH_PATH,"a.patch") }
  RSpec.shared_examples "collections" do |repo_path, source_repo_path, source_branch, target_branch|
    it('test'){(1+1).should == 2}
    describe "commits_and_diffs" do
      subject {Gitlab::Git::MergeRepo.commits_and_diffs(repo_path, target_branch, source_branch, source_repo_path)}
      it('Gitlab::Git::MergeRepo.commits_and_diffs') { should be_kind_of Hash}
      if $for_right
        it { should include({timeout_diffs: false, diffs_size: 5, commits_size: 7})}
      end
    end

    describe "cache" do
      subject {Gitlab::Git::MergeRepo.cache(repo_path, target_branch, source_branch, source_repo_path)}
      it('Gitlab::Git::MergeRepo.cache') { should be_kind_of Hash}
      if $for_right
        it { should include({timeout_diffs: false, diffs_size: 5, commits_size: 7})}
      end
    end

    describe "save_patch" do
      subject! {Gitlab::Git::MergeRepo.save_patch(repo_path, target_branch, source_branch, source_repo_path, {patch_name: "b.patch"})}
      it('Gitlab::Git::MergeRepo.save_patch') { should be_kind_of Array}
      if $for_right
        it { File.exists?("#{SeedRepo::Repo::DEFAULT_PATCH_PATH}b.patch").should be_true }
      end
      after(:all) { FileUtils.rm_r("#{SeedRepo::Repo::DEFAULT_PATCH_PATH}b.patch") }
    end

    describe "merge_conflict_files" do
      subject {Gitlab::Git::MergeRepo.merge_conflict_files(repo_path, target_branch, source_branch, source_repo_path)}
      it('Gitlab::Git::MergeRepo.merge_conflict_files') { should be_kind_of Array}
      if $for_right
        its(:size) {should == 1}
      end
      describe "automerge!" do
        subject {Gitlab::Git::MergeRepo.automerge!(repo_path, target_branch, source_branch, source_repo_path, {username: "liuhq002", useremail: "liuhq@csdn.net"})}
        it('Gitlab::Git::MergeRepo.automerge!') { should be_kind_of Array }
        if $for_right
          it { should start_with(false) }
        end
      end
    end
  end

  RSpec.describe "same_repo" do
    include_examples "collections", SeedConfig::REPO_PATH, nil, "master", "test_merge_same"
  end

  RSpec.describe "diff_repo" do
    include_examples "collections", SeedConfig::REPO_PATH, SeedConfig::MERGE_PATH, "master", "test_merge_diff"
  end
end
