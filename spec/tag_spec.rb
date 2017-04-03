require "spec_helper"

describe Gitlab::Git::Tag do
  context 'when first tag ' do
    before(:all) do
      @tag = $repository.tags.first
    end
    describe :name do
      subject{@tag.name}
      it('tag.name'){ should_not be_nil }
    end
    describe :utf8_name do
      subject{@tag.utf8_name}
      it('tag.utf8_name'){ should_not be_nil }
      it {@tag.utf8_name.encoding.to_s.should == "UTF-8"}
    end
    describe :utf8_message do
      let(:um){@tag.utf8_message}
      context 'when utf8_message is exist' do
        it do
          um.encoding.to_s.should == "UTF-8" if um
        end
      end
    end
    describe :commit do
      subject{@tag.commit($repository)}
      it('tag.commit') {should be_kind_of Gitlab::Git::Commit}
    end
    if $for_right
      describe 'first tag' do
        let(:tag) { $repository.tags.first }

        it { tag.name.should == "v1.0.0" }
        it { tag.target.should == "f4e6814c3e4e7a0de82a9e7cd20c626cc963a2f8" }
        it { tag.message.should == "Release" }
      end

      describe 'last tag' do
        let(:tag) { $repository.tags.last }

        it { tag.name.should == "v1.2.1" }
        it { tag.target.should == "2ac1f24e253e08135507d0830508febaaccf02ee" }
        it { tag.message.should == "Version 1.2.1" }
      end

      it { $repository.tags.size.should == SeedRepo::Repo::TAGS.size }
    end
  end
end
