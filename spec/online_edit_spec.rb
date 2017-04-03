require "spec_helper"

describe Gitlab::Git::OnlineEdit do
  include EncodingHelper

  let(:path) { 'b/a.txt' }
  let(:path1) { 'b/a1.txt' }
  let(:content) { 'Just do it!' }

  before(:all) do
    @branch_name = 'master'
    @online_edit = Gitlab::Git::OnlineEdit.new(SeedConfig::REPO_PATH, @branch_name)
    @repo = Gitlab::Git::Repository.new(SeedConfig::REPO_PATH)
    @old_last_commit = Gitlab::Git::Commit.last_for_path(@repo, @branch_name).id
    @content1 = "I have done! #{rand(1000)}"
  end

  describe :write_page do
    subject do
      @online_edit.write_page(path, content)
      @online_edit.update_page(path, path1, @content1)
      @online_edit.commit({author_name: 'test001', author_email: 'test001@csdn.net', message: "do a online edit"})
    end

    it("online_edit commit") { should == Gitlab::Git::Commit.last_for_path(@repo, @branch_name).id }
    it { should_not == @old_last_commit }

    describe "author" do
      subject { Gitlab::Git::Commit.last_for_path(@repo, @branch_name).author }
      it { should include(:name => "test001", :email => "test001@csdn.net") }
    end

    describe "content" do
      subject do
        Gitlab::Git::Blob.find(@repo, 'master', path1).data
      end
      it { should == @content1 }
    end
  end

end
