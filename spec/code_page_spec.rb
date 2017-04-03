require "page_spec_helper"
#require 'gitlab_git_client'

describe "Simulation code page" do
  before(:all) do
    @repo = Gitlab::Git::Repository.new(PAGE_REPO_PATH)
    @commit = @repo.commit("master")
    @tree = @commit.tree_rpc
  end

  it "should not be empty" do
    @repo.empty?.should be_false
  end

  it "should have at least one branch_names" do
    @repo.branch_names.size.should > 0
  end
  
  it "should have at least zero tag_names" do
    @repo.tag_names.size.should >= 0
  end

  it "repo.commit('master') should be kind of Gitlab::Git::Commit" do
    @commit.should be_kind_of Gitlab::Git::Commit
  end
  
  it "should not be empty second" do
    @repo.empty?.should be_false
  end

  it "commit.tree_rpc should be Gitlab::Git::Tree" do
    @tree.should be_kind_of Gitlab::Git::Tree
  end
  
  it "repo.commit('HEAD') should be kind of Gitlab::Git::Commit" do
    @repo.commit("HEAD").should be_kind_of Gitlab::Git::Commit
  end
  
  it "repo.commit('HEAD') should be kind of Gitlab::Git::Commit second" do
    @repo.commit("HEAD").should be_kind_of Gitlab::Git::Commit
  end

  it "repo.commits should have one Gitlab::Git::Commit with args('master', 1, nil)" do
    @repo.commits('master', 1, nil).size.should == 1 
  end

  it "repository initialize second" do
    Gitlab::Git::Repository.new(PAGE_REPO_PATH).should_not be_nil
  end

  it "Gitlab::Git::Tree.tree_contents should hava at least one element" do
    Gitlab::Git::Tree.tree_contents(@repo, @tree.id, "", @commit.id, true).size.should > 0
  end

  it "should have at least one branch" do
    @repo.branches.size.should > 0
  end
  
  it "should have at least zero tag" do
    @repo.tags.size.should >= 0
  end

  it "should have at least one branch second" do
    @repo.branches.size.should > 0
  end

  it "should have at least zero tag second" do
    @repo.tags.size.should >= 0
  end

  it "repo.commit('HEAD') should be kind of Gitlab::Git::Commit third" do
    @repo.commit("HEAD").should be_kind_of Gitlab::Git::Commit
  end

  it "repo.commit('HEAD') should be kind of Gitlab::Git::Commit fourth" do
    @repo.commit("HEAD").should be_kind_of Gitlab::Git::Commit
  end

  it "repository initialize third" do
    Gitlab::Git::Repository.new(PAGE_REPO_PATH).should_not be_nil
  end
end
