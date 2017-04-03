require "spec_helper"

describe Gitlab::Git::Commit do

  let(:commit_id) { $commit.id }
  let(:parent_commit) { $commit.parents_rpc.first }
  let(:repository) { $repository }
  let(:commit) {
    $commit
    # Gitlab::Git::Commit.find($repository, commit_id)
  }

  context 'Class methods' do
    describe :find do
      it "Commit.last,should return first head commit if without params" do
        Gitlab::Git::Commit.last(repository).id.should ==
            repository.raw.head.target.oid
      end

      if $for_right
        it "Commit.find,should return valid commit" do
          Gitlab::Git::Commit.find(repository, commit_id).should be_valid_commit
        end

        it "Commit.find,should return valid commit for tag" do
          Gitlab::Git::Commit.find(repository, 'v1.0.0').id.should == '6f6d7e7ed97bb5f0054f2b1df789b39ca89b6ff9'
        end

        it "Commit.find,should return nil for non-commit ids" do
          blob = Gitlab::Git::Blob.find(repository, SeedRepo::Commit::ID, "files/ruby/popen.rb")
          Gitlab::Git::Commit.find(repository, blob.id).should be_nil
        end

        it "Commit.find,should return nil for parent of non-commit object" do
          blob = Gitlab::Git::Blob.find(repository, SeedRepo::Commit::ID, "files/ruby/popen.rb")
          Gitlab::Git::Commit.find(repository, "#{blob.id}^").should be_nil
        end

        it "Commit.find,should return nil for nonexisting ids" do
          Gitlab::Git::Commit.find(repository, "+123_4532530XYZ").should be_nil
        end
      end
    end

    describe :last_for_path do
      context 'no path' do
        let(:no_path) { Gitlab::Git::Commit.last_for_path(repository, 'master') }
        if $for_right
          it('Gitlab::Git::Commit.last_for_path no_path') { no_path.id.should == SeedRepo::LastCommit::ID }
        end
      end

      context 'path' do
        let(:with_path) { Gitlab::Git::Commit.last_for_path(repository, 'master', 'files/ruby') }
        if $for_right
          it('Gitlab::Git::Commit.last_for_path with_path') { with_path.id.should == SeedRepo::Commit::ID }
        else
          it('Gitlab::Git::Commit.last_for_path with_path') { [true,false].should include(with_path.nil?) }
        end
      end

      context 'ref + path' do
        let(:with_ref_path) { Gitlab::Git::Commit.last_for_path(repository, SeedRepo::Commit::ID, 'encoding') }
        if $for_right
          it('Gitlab::Git::Commit.last_for_path with_ref_path') { with_ref_path.id.should == SeedRepo::BigCommit::ID }
        end
      end
    end


    describe "where" do
      context 'ref is branch name' do
        if $for_right
          subject do
            commits = Gitlab::Git::Commit.where(
                repo: repository,
                ref: 'master',
                path: 'files',
                limit: 3,
                offset: 1
            )

            commits.map { |c| c.id }
          end

          it('Gitlab::Git::Commit.where ref is a branch name') { should have(3).elements }
          it { should include("874797c3a73b60d2187ed6e2fcabd289ff75171e") }
          it { should_not include("eb49186cfa5c4338011f5f590fac11bd66c5c631") }
        else
          let(:commit_ids) { Gitlab::Git::Commit.where(repo: repository, ref: 'master', path: 'files', limit: 3, offset: 1).map { |c| c.id } }
          it('Gitlab::Git::Commit.where ref is a branch name') { commit_ids.should_not be_nil }
        end

      end

      context 'ref is commit id' do
        if $for_right
          subject do
            commits = Gitlab::Git::Commit.where(
                repo: repository,
                ref: "874797c3a73b60d2187ed6e2fcabd289ff75171e",
                path: 'files',
                limit: 3,
                offset: 1
            )

            commits.map { |c| c.id }
          end

          it('Gitlab::Git::Commit.where ref is a commit id') { should have(3).elements }
          it { should include("2f63565e7aac07bcdadb654e253078b727143ec4") }
          it { should_not include(SeedRepo::Commit::ID) }
        else
          let(:commit_ids) { Gitlab::Git::Commit.where(repo: repository, ref: $commit.id, limit: 3, offset: 1).map { |c| c.id } }
          it('Gitlab::Git::Commit.where ref is a commit id') { commit_ids.should_not be_empty }
        end
      end

      context 'ref is tag' do
        if $for_right
          subject do
            commits = Gitlab::Git::Commit.where(
                repo: repository,
                ref: 'v1.0.0',
                path: 'files',
                limit: 3,
                offset: 1
            )

            commits.map { |c| c.id }
          end

          it { should have(3).elements }
          it { should include("874797c3a73b60d2187ed6e2fcabd289ff75171e") }
          it { should_not include(SeedRepo::Commit::ID) }
        else
          if $tag_name
            let(:commit_ids) { Gitlab::Git::Commit.where(repo: repository, ref: 'v1.0.0', limit: 3, offset: 1).map { |c| c.id } }
            it('Gitlab::Git::Commit.where ref is a tag name') { commit_ids.should_not be_empty }
          end
        end
      end
    end

    describe :between do
      subject do
        commits = Gitlab::Git::Commit.between_rpc(repository, parent_commit.id, commit_id)
        commits.map { |c| c.id }
      end
      # it { should have(1).elements }
      it('Gitlab::Git::Commit.between_rpc') { should include(commit_id) }
    end

    describe :find_all do
      context 'max_count' do
        subject do
          commits = Gitlab::Git::Commit.find_all(
              repository,
              max_count: 50
          )

          commits.map { |c| c.id }
        end
        if $for_right
          # it{ should have(25).elements }
          it('Gitlab::Git::Commit.find_all(max_count:50) max_count') { should include(SeedRepo::Commit::ID) }
          it { should include(SeedRepo::Commit::PARENT_ID) }
        else
          it('Gitlab::Git::Commit.find_all(max_count:50) max_count') { should_not be_empty }
        end
      end

      context 'ref + max_count + skip' do
        subject do
          commits = Gitlab::Git::Commit.find_all(
              repository,
              ref: 'master',
              max_count: 50,
              skip: 1
          )

          commits.map { |c| c.id }
        end
        if $for_right
          # it { should have(18).elements }
          it('Gitlab::Git::Commit.find_all ref + max_count + skip') { should include(SeedRepo::Commit::ID) }
          it { should include(SeedRepo::FirstCommit::ID) }
          it { should_not include(SeedRepo::LastCommit::ID) }
        else
          it('Gitlab::Git::Commit.find_all ref + max_count + skip') { should be_kind_of Array }
        end
      end

      context 'contains feature + max_count' do
        subject do
          commits = Gitlab::Git::Commit.find_all(
              repository,
              contains: 'master',
              max_count: 7
          )

          commits.map { |c| c.id }
        end
        if $for_right
          # it { should have(7).elements }
          it('Gitlab::Git::Commit.find_all contains feature + max_count') { should_not include(SeedRepo::Commit::PARENT_ID) }
          it { should_not include(SeedRepo::Commit::ID) }
          it { should include('732401c65e924df81435deb12891ef570167d2e2') }
        else
          it('Gitlab::Git::Commit.find_all contains feature + max_count') { should be_kind_of Array }
        end
      end
    end
  end

  describe :init_from_hash do
    let(:commit) { Gitlab::Git::Commit.new(sample_commit_hash) }
    subject { commit }

    its(:id) { should == sample_commit_hash[:id] }
    its(:message) { should == sample_commit_hash[:message] }
  end

  if $for_right
    describe :stats do
      let(:commit_right) {Gitlab::Git::Commit.find($repository, SeedRepo::Commit::ID)}
      subject { commit_right.stats }

      its(:additions) { should eq(11) }
      its(:deletions) { should eq(6) }
    end
    describe :has_zero_stats? do
      let(:commit_right) {Gitlab::Git::Commit.find($repository, SeedRepo::Commit::ID)}
      it('commit.has_zero_stats?') { commit_right.has_zero_stats?.should == false }
    end
  else
    describe :stats do
      let(:stats) { commit.stats }
      it('commit.stats') { stats.should be_kind_of Gitlab::Git::CommitStats }
    end
    describe :has_zero_stats? do
      it('commit.has_zero_stats?') { [true, false].should include commit.has_zero_stats? }
    end
  end


  describe :to_diff do
    let(:to_diff) { commit.to_diff }
    if $for_right
      it('commit.to_diff') { to_diff.should_not include "From #{SeedRepo::Commit::ID}" }
      it('commit.to_diff') { to_diff.should include 'diff --git' }
    else
      it('commit.to_diff') { to_diff.should include 'diff --git' }
    end
  end

  # describe :has_zero_stats? do
  #   if $for_right
  #
  #     it('commit.has_zero_stats?') { commit.has_zero_stats?.should == false }
  #   else
  #     # it('commit.has_zero_stats?') { commit.has_zero_stats? }
  #   end
  # end

  describe :to_patch do
    subject { commit.to_patch }
    if $for_right
      it('commit.to_patch') { should include "From #{SeedRepo::Commit::ID}" }
    end
    it('commit.to_patch') { should include 'diff --git' }
  end

  describe :to_hash do
    let(:hash) { commit.to_hash }
    subject { hash }

    it('to_hash') { should be_kind_of Hash }
    # its(:keys) { should include?(:author_name) }
  end


  describe :diffs_rpc do
    let(:diff_rpc) { commit.diffs_rpc }
    it('commit.diffs_rpc') { diff_rpc.should be_kind_of Hash }
    if $for_right
      it { diff_rpc[:diffs_size].should eq(2) }
      it { diff_rpc[:diffs].first.should be_kind_of Gitlab::Git::Diff }
    end
  end

  describe :ref_names do
    let(:commit) { Gitlab::Git::Commit.find(repository, 'master') }
    subject { commit.ref_names_rpc }
    it('commit.ref_names') { should have(1).elements }
    if $for_right
      it { should include("master") }
      it { should_not include("feature") }
    end
  end

  def sample_commit_hash
    {
        author_email: "dmitriy.zaporozhets@gmail.com",
        author_name: "Dmitriy Zaporozhets",
        authored_date: "2012-02-27 20:51:12 +0200",
        committed_date: "2012-02-27 20:51:12 +0200",
        committer_email: "dmitriy.zaporozhets@gmail.com",
        committer_name: "Dmitriy Zaporozhets",
        id: SeedRepo::Commit::ID,
        message: "tree css fixes",
        parent_ids: ["874797c3a73b60d2187ed6e2fcabd289ff75171e"]
    }
  end

end
