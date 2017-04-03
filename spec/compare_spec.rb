require "spec_helper"

describe Gitlab::Git::Compare do
  let(:compare) { Gitlab::Git::Compare.new($repository, $commit2.id, $commit.id) }
  it('Gitlab::Git::Compare.new'){compare.should_not be_nil}

  context 'when compare is exist' do
    before(:all) do
      @compare = Gitlab::Git::Compare.new($repository, $commit2.id, $commit.id)
    end

    describe :commits do
      subject do
        compare.commits.map(&:id)
      end
      it('compare.commits'){should be_kind_of Array}
      if $for_right
        it { should have(8).elements }
        it { should include(SeedRepo::Commit::PARENT_ID) }
        it { should_not include(SeedRepo::BigCommit::PARENT_ID) }
      end
    end

    describe :diffs do
      subject do
        compare.diffs(nil, {offset: 0, limit: 10})
      end
      # let(:diffs){compare.diffs}
      it('compare.diffs'){ should be_kind_of Array}
      it { should have(2).elements }
      context 'when  diffs.first not empty' do
        if $for_right
          subject {compare.diffs.first.map(&:new_path)}
          it { should include('.gitignore') }
          it { should_not include('LICENSE') }
          it { compare.timeout_diffs.should be_false }
          it { compare.empty_diff?.should be_false }
        end
      end
    end
  end

  describe 'non-existing refs' do
    let(:compare) { Gitlab::Git::Compare.new($repository, 'no-such-branch', '1234567890') }
    it { compare.commits.should be_empty }
    it { compare.diffs.should be_empty }
  end
end
