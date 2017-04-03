require "spec_helper"

describe Gitlab::Git::Branch do

  describe 'first branch' do
    if $for_right
      it do
        $repository.branches.should be_kind_of Array
        $repository.branches.size.should eq(SeedRepo::Repo::BRANCHES.size)
      end

      describe 'first branch' do
        let(:branch) { $repository.branches.first }

        it { branch.name.should == SeedRepo::Repo::BRANCHES.first }
        it { p branch.name,branch.target; branch.target.should == "0b4bc9a49b562e85de7cc9e834518ea6828729b9" }
      end

      describe 'master branch' do
        let(:branch) { $repository.branches.select{|bs| bs.name=='master'}.first }

        it { branch.name.should == 'master' }
        it { branch.target.should == SeedRepo::LastCommit::ID }
      end

    end
    context "when is not test for right" do
      before(:all) do
        @branch = $repository.branches.first
      end
      describe :utf8_name do
        it('branch.utf8_name'){@branch.utf8_name.should_not be_nil }
        it{ @branch.utf8_name.encoding.to_s.should == "UTF-8" }
      end
      describe :commit do
        let(:commit){ @branch.commit($repository) }
        it('branch.commit'){commit.should_not be_nil}
        it{ commit.should be_kind_of Gitlab::Git::Commit }
      end
    end
  end
end
