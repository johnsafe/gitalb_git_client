require "spec_helper"

describe Gitlab::Git::OnlineEdit do
  include EncodingHelper

  let(:path) { 'b/a.txt' }
  let(:content) { "## Just do it!" }

  before(:all) do
    @bare_repo_path = SeedConfig::DOC_PATH
    @bare_full_path = "#{SeedConfig::PRE_PATH}#{@bare_repo_path}"
    Gitlab::Git::Repository.init(@bare_repo_path)
    branch_name = 'master'
    @online_edit = Gitlab::Git::OnlineEdit.new(@bare_repo_path, branch_name)
    @online_edit.write_page(path, content)
    @online_edit.commit({author_name: 'test001', author_email: 'test001@csdn.net', message: "write a simple snippet"})
    @online_edit.reflash_order_and_index
    @online_edit.commit({author_name: 'test001', author_email: 'test001@csdn.net', message: "write a simple snippet"})
  end

  it "doc bare should exist" do
    expect(File.exist?(@bare_full_path)).to be_true
  end

  it {@online_edit.new_file_list.should == [path]}

  it "doc bare get_head_arr should be an array" do
    @online_edit.get_head_arr.should == ["##0.1 [ Just do it!](b/a.txt#anchor_0)"]
  end

  after(:all) do
    FileUtils.rm_rf(@bare_full_path)
  end

end
