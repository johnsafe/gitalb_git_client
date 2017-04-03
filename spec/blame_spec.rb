require "spec_helper"

describe Gitlab::Git::Blame do
  let(:blame) do
    Gitlab::Git::Blame.new($repository, $commit.id, $blob.path)
  end

  it "Gitlab::Git::Blame.new" do
    blame.should_not be_nil
  end

  context "each count" do
    it "blame.each" do
      exist = false
      blame.each do |commit, hunk_lines|
        commit.should be_kind_of Gitlab::Git::Commit
        exist = true if hunk_lines.first == $blob.utf8_data.split("\n").first
      end
      exist.should be_true
    end
  end
end