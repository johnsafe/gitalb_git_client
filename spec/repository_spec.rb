require "spec_helper"

describe Gitlab::Git::Repository do
  include EncodingHelper

  let(:repository) { Gitlab::Git::Repository.new(SeedConfig::REPO_PATH) }
  describe "Respond to" do
    subject { repository }

    its(:raw) { should_not raise_error }
    its(:rugged) { should_not raise_error }
    its(:root_ref) { should_not raise_error }
    its(:tags){ should_not raise_error }
  end

  if $for_right
    describe "#discover_default_branch" do
      let(:master) { 'master' }
      let(:feature) { 'feature' }
      let(:feature2) { 'feature2' }

      it "returns 'master' when master exists" do
        repository.branch_names.should include(feature, master)
        repository.discover_default_branch.should == 'master'
      end


      it "returns non-master when master exists but default branch is set to something else" do
        File.write(File.join(TEST_REPO_PATH, 'HEAD'), 'ref: refs/heads/feature')
        repository.branch_names.should include(feature, master)
        repository.discover_default_branch.should == 'feature'
        File.write(File.join(TEST_REPO_PATH, 'HEAD'), 'ref: refs/heads/master')
      end
    end
  end

  describe :logs do
    subject {repository.log({ref: 'master',limit: 9999999, offset:0}).size}
    it('repository.log (master)commits size(all)'){should > 0}
  end

  describe :branch_names do
    subject { repository.branch_names }
    if $for_right
      it { should have(SeedRepo::Repo::BRANCHES.size).elements }
      it { should include("master") }
    end
    it('repository.branch_names') { should_not include("branch-from-space") }
  end

  describe :tags do
    subject { repository.tags }
    it('repository.tags') { should be_kind_of Array }
    it { should have(SeedRepo::Repo::TAGS.size).elements } if $for_right
  end

  describe :tag_names do
    subject { repository.tag_names }

    it('repository.tag_names') { should be_kind_of Array }
    if $for_right
      it { should have(SeedRepo::Repo::TAGS.size).elements }
      its(:last) { should == "v1.2.1" }
      it { should include("v1.0.0") }
      it { should_not include("v5.0.0") }
    end
  end
=begin
  describe :format_patch do
    subject { repository.format_patch('master','feature') }
    it('repository.format_patch') { should_not be_nil }
  end
=end
  describe :find_commits do
    context 'with options' do

      let(:f_commits) do
        repository.find_commits(
            max_count: 50,
            ref: 'master'
        ).map { |c| c.id }
      end
      it('repository.find_commits') { f_commits.size.should > 0 }
      if $for_right
        it { f_commits.should include(SeedRepo::Commit::ID) }
        it { f_commits.should include(SeedRepo::Commit::PARENT_ID) }
        it { f_commits.should include(SeedRepo::FirstCommit::ID) }
      end
    end
  end
=begin
  describe :diff_with_size do
    subject { repository.diff_with_size('master','feature').first.first }
    it('repository.diff_with_size') { should be_kind_of Gitlab::Git::Diff }
  end

  describe :format_patch_by_cmd do
    subject { repository.format_patch_by_cmd('master','feature').last }
    it('repository.format_patch_by_cmd') { should == 0 }
  end
=end
  describe :merge_conflicts? do
    # subject { repository.merge_conflicts?('master','feature') }
    it('repository.merge_conflicts?') { [true, false].should include repository.merge_conflicts?('master','feature') }
  end

  describe :config do
    subject { repository.config('user.name') }
    it('repository.config') { should be_kind_of String }
  end

  shared_examples 'archive check' do |extenstion|
    it("repository.archive   #{extenstion}") { archive.should match(/tmp\/.*-master-/) }
    it { archive.should end_with extenstion }
    it { File.exists?(archive).should be_true }
    it { File.size?(archive).should_not be_nil }
  end

  if $for_right
    describe :archive do
      let(:archive) { repository.archive_repo('master', '/tmp') }
      after { FileUtils.rm_r(archive) }

      it_should_behave_like 'archive check', '.tar.gz'
    end

    describe :archive_zip do
      let(:archive) { repository.archive_repo('master', '/tmp', 'zip') }
      after { FileUtils.rm_r(archive) }

      it_should_behave_like 'archive check', '.zip'
    end

    describe :archive_bz2 do
      let(:archive) { repository.archive_repo('master', '/tmp', 'tbz2') }
      after { FileUtils.rm_r(archive) }

      it_should_behave_like 'archive check', '.tar.bz2'
    end

    describe :archive_fallback do
      let(:archive) { repository.archive_repo('master', '/tmp', 'madeup') }
      after { FileUtils.rm_r(archive) }

      it_should_behave_like 'archive check', '.tar.gz'
    end
  else
=begin
    describe :archive_repo do
      it('repository.archive_repo{drb_timeout: 3600}') { repository.archive_repo('master', '/tmp').should be_kind_of String}
    end
=end
  end

  describe :size do
    subject { repository.size }

    it('repository.size') { should be_kind_of Float }
  end

  describe :has_commits? do
    it('repository.has_commits?') { repository.has_commits?.should be_true }
  end

  describe :empty? do
    it('repository.empty?') { repository.empty?.should be_false }
  end

  describe :bare? do
    it('repository.bare?') { repository.bare?.should be_true }
  end

  describe :heads do
    let(:heads) { repository.heads }
    subject { heads }

    it('repository.heads') { should be_kind_of Array }
    if $for_right
      its(:size) { should eq(SeedRepo::Repo::BRANCHES.size) }

      context :head do
        subject { heads.first }

        its(:name) { should == "feature" }

        context :commit do
          subject { heads.first.target }

          it { should be_kind_of String }
        end
      end
    end
  end

  describe :ref_names do
    let(:ref_names) { repository.ref_names }
    subject { ref_names }

    it('repository.ref_names') { should be_kind_of Array }
    if $for_right
      its(:first) { should == 'feature' }
      its(:last) { should == 'v1.2.1' }
    end
  end

  # search_files is not used in client
=begin
  describe :search_files do
    let(:results) { repository.search_files('rails', 'master', {drb_timeout: 3600}) }
    subject { results }

    it('repository.search_files') { should be_kind_of Array }
    if $for_right
      its(:first) { should be_kind_of Gitlab::Git::BlobSnippet }

      context 'blob result' do
        subject { results.first }

        its(:ref) { should == 'master' }
        its(:filename) { should == 'CHANGELOG' }
        its(:startline) { should == 35 }
        its(:data) { should include "Ability to filter by multiple labels" }
      end
    end
  end
=end
  if $for_right
    context :submodules do
      let(:repository) { Gitlab::Git::Repository.new(SeedConfig::REPO_PATH) }

      context 'where repo has submodules' do
        let(:submodules) { repository.submodules('master') }
        let(:submodule) { submodules.first }

        it { submodules.should be_kind_of Hash }
        it { submodules.empty?.should be_false }

        it 'should have valid data' do
          submodule.should == [
            "six", {
              "id"=>"409f37c4f05865e4fb208c771485f211a22c4c2d",
              "path"=>"six",
              "url"=>"git://github.com/randx/six.git"
            }
          ]
        end

        it 'should handle nested submodules correctly' do
          nested = submodules['nested/six']
          expect(nested['path']).to eq('nested/six')
          expect(nested['url']).to eq('git://github.com/randx/six.git')
          expect(nested['id']).to eq('24fb71c79fcabc63dfd8832b12ee3bf2bf06b196')
        end

        it 'should handle deeply nested submodules correctly' do
          nested = submodules['deeper/nested/six']
          expect(nested['path']).to eq('deeper/nested/six')
          expect(nested['url']).to eq('git://github.com/randx/six.git')
          expect(nested['id']).to eq('24fb71c79fcabc63dfd8832b12ee3bf2bf06b196')
        end

        it 'should not have an entry for an invalid submodule' do
          expect(submodules).not_to have_key('invalid/path')
        end

        it 'should not have an entry for an uncommited submodule dir' do
          submodules = repository.submodules('fix-existing-submodule-dir')
          expect(submodules).not_to have_key('submodule-existing-dir')
        end

        it 'should handle tags correctly' do
          submodules = repository.submodules('v1.2.1')
          submodule.should == [
            "six", {
              "id"=>"409f37c4f05865e4fb208c771485f211a22c4c2d",
              "path"=>"six",
              "url"=>"git://github.com/randx/six.git"
            }
          ]
        end
      end

      context 'where repo doesn\'t have submodules' do
        let(:submodules) { repository.submodules('6d39438') }
        it 'should return an empty hash' do
          expect(submodules).to be_empty
        end
      end
    end
  end

  describe :commit_count do
    it('repository.commit_count') { repository.commit_count("master").should > 0 }
    if $for_right
      it { repository.commit_count("master").should == 21 }
      it { repository.commit_count("feature").should == 9 }
    end
  end

=begin
  describe "#delete_branch" do
    before(:all) do
      @repo = Gitlab::Git::Repository.new(SeedConfig::REPO_PATH)
      @repo.delete_branch("feature")
    end

    it "should remove the branch from the repo" do
      expect(@repo.rugged.branches["feature"]).to be_nil
    end

    it "should update the repo's #heads collection" do
      expect(@repo.heads).not_to include("feature")
    end

    after(:all) do
      FileUtils.rm_rf(TEST_REPO_PATH)
      ensure_seeds
    end
  end
=end

  describe "#remote_names" do
    let(:remotes) { repository.remote_names }
    it('repository.remote_names'){ expect(remotes).to have(1).items }
    it {expect(remotes.first).to eq("origin")}

  end

  describe "#refs_hash" do
    let(:refs) { repository.refs_hash }
    it('repository.refs_hash'){ refs.should_not be_nil}

    #should have as many entries as branches and tags
    it do
      expected_refs = SeedRepo::Repo::BRANCHES + SeedRepo::Repo::TAGS
      expect(refs.size).to have_at_least(1).items
      expect(refs.size).to have_at_most(expected_refs.size).items
    end
  end

  describe "#remote_add" do
    before(:all) do
      @repo = Gitlab::Git::Repository.new(SeedConfig::REPO_PATH)
      @repo.remote_add("new_remote", "https://code.csdn.net/liuhq002/ruby_editormd.git")
    end

    #should add the remote
    it do
      expect(@repo.rugged.remotes.each_name.to_a).to include("new_remote")
    end

    describe "#remote_delete" do
      before(:all) do
        @repo = Gitlab::Git::Repository.new(SeedConfig::REPO_PATH)
        @repo.remote_delete("new_remote")
      end

      #should remove the remote
      it do
        expect(@repo.rugged.remotes).not_to include("new_remote")
      end
    end

    if $for_right
      after(:all) do
        FileUtils.rm_rf(TEST_REPO_PATH)
        ensure_seeds
      end
    end
  end

  # need to fix
  # describe "#remote_update" do
  #   before(:all) do
  #     @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
  #     @repo.remote_update("expendable", {url: TEST_NORMAL_REPO_PATH})
  #   end
  #
  #   it "should add the remote" do
  #     expect(@repo.rugged.remotes["expendable"].url).to(
  #         eq(TEST_NORMAL_REPO_PATH)
  #     )
  #   end
  #
  #   after(:all) do
  #     FileUtils.rm_rf(TEST_MUTABLE_REPO_PATH)
  #     ensure_seeds
  #   end
  # end

  describe "branch_names_contains" do
    subject { repository.branch_names_contains($commit.id) }

    it('repository.branch_names_contains') { should include('master') }
    if $for_right
      it { should_not include('feature') }
      it { should_not include('fix') }
    end
  end

=begin
  describe '#autocrlf' do
    before(:all) do
      @repo = Gitlab::Git::Repository.new(SeedConfig::REPO_PATH)
      @repo.rugged.config['core.autocrlf'] = true
    end

    describe 'repository.branch_names_contains' do
      it { expect(@repo.autocrlf).to be(true) }
    end


    after(:all) do
      @repo.rugged.config.delete('core.autocrlf')
    end
  end

  describe '#autocrlf=' do
    before(:all) do
      @repo = Gitlab::Git::Repository.new(SeedConfig::REPO_PATH)
      @repo.rugged.config['core.autocrlf'] = false
    end

    describe 'should set the autocrlf option to the provided option' do
      it do
        @repo.autocrlf = :input
        File.open(File.join(TEST_REPO_PATH, 'config')) do |config_file|
          expect(config_file.read).to match('autocrlf = input')
        end
      end
    end

    after(:all) do
      @repo.rugged.config.delete('core.autocrlf')
    end
  end
=end

  describe :tree do
    let(:repo_tree) { repository.tree('master', $blob.path) }
    it 'repository.tree' do
      expect(repo_tree).to be_kind_of Gitlab::Git::Tree
    end
    it do
      expect(repo_tree.path).to eq($blob.path)
    end
  end

  describe :ls_blob_names do
    subject { repository.ls_blob_names }
    it('repository.ls_blob_names') { should be_kind_of Array }
    it { should include($blob.path)}
  end

  describe :blob_by_commit_and_path do
    subject { repository.blob_by_commit_and_path('master', $blob.path) }
    it('repository.blob_by_commit_and_path') { should be_kind_of Gitlab::Git::Blob }
  end

  describe :commits do
    subject { repository.commits }
    it('repository.commits') { should be_kind_of Array }
  end

  describe :commit do
    subject { repository.commit($commit.id) }
    it('repository.commit') { should be_kind_of Gitlab::Git::Commit }
  end

  describe :repo_exists? do
    it('repository.repo_exists?') { repository.repo_exists?.should be_true }
  end

  describe :fetch do
    subject { repository.fetch('origin') }
    it('repository.fetch') { should be_kind_of Hash }
  end

  # describe :merge do
  #   let(:author) { {:email=>"tanoku@gmail.com", :time=>Time.now, :name=>"Vicent Mart\303\255"} }
  #   subject { repository.merge('master','master',{author:author,message:"Hello world\n\n",committer:author}) }
  #   it { should_not be_nil }
  # end


  describe :lstree do
    subject { repository.lstree('master') }
    it('repository.lstree') { should be_kind_of Array }
  end
end
