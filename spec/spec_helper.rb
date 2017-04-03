require 'benchmark'
require 'support/example'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

require 'gitlab_git_client'
require 'pry'

require_relative 'support/seed_config'
$for_right = SeedConfig::FOR_RIGHT
require_relative 'support/seed_helper' if $for_right
require_relative 'support/commit'
require_relative 'support/first_commit'
require_relative 'support/last_commit'
require_relative 'support/big_commit'
require_relative 'support/ruby_blob'
require_relative 'support/repo'

if $for_right
  RSpec::Matchers.define :be_valid_commit do
    match do |actual|
      actual != nil
      actual.id == SeedRepo::Commit::ID
      actual.message == SeedRepo::Commit::MESSAGE
      actual.author_name == SeedRepo::Commit::AUTHOR_FULL_NAME
    end
  end

  SUPPORT_PATH = File.join(SeedConfig::PRE_PATH, "code_test")
  MERGE_PATH = "merge.git"
  TEST_REPO_PATH = File.join(SUPPORT_PATH, 'gitlab-git-test.git')
# TEST_NORMAL_REPO_PATH = File.join(SUPPORT_PATH, "not-bare-repo.git")
# TEST_MUTABLE_REPO_PATH = File.join(SUPPORT_PATH, "mutable-repo.git")

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.filter_run :focus
    config.order = 'random'
    config.include SeedHelper
    config.before(:all) do
      ensure_seeds
      $repository = Gitlab::Git::Repository.new(SeedConfig::REPO_PATH)
      $branch = 'master'
      $branch1 = 'feature'
      $tag_name = 'v1.0.0'
      $commit = Gitlab::Git::Commit.find($repository, SeedRepo::Commit::ID)
      $commit2 = Gitlab::Git::Commit.find($repository, SeedRepo::BigCommit::ID)
      $tree = $commit.tree_rpc
      $blob = Gitlab::Git::Blob.find($repository, SeedRepo::Commit::ID, 'CONTRIBUTING.md')
      $last_commit_id = SeedRepo::LastCommit::ID
    end
  end
else
  TEST_REPO_PATH = File.join(SeedConfig::PRE_PATH, SeedConfig::REPO_PATH)
  $repository = Gitlab::Git::Repository.new(SeedConfig::REPO_PATH)
  raise 'empty repository' if $repository.empty?
  $branch = 'master'
  branches = $repository.branches.map(&:name)-['master']
  raise 'branches too less' if branches.size<2
  $branch1 = branches.first
  $branch1 = branches.last
  tag_names = $repository.tag_names
  $tag_name = tag_names.empty? ? '' : tag_names.first
  $commit = Gitlab::Git::Commit.find($repository,'master')
  $commit2 = $repository.commits('master',8000,0).last
  $tree = $commit.tree_rpc
  $blob = $tree.blobs.first
end
