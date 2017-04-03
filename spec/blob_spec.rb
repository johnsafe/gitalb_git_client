# encoding: UTF-8

require "spec_helper"

describe Gitlab::Git::Blob do
  let(:blob_id) {$for_right ? SeedRepo::RubyBlob::ID : $blob.id}
  describe '.blame' do
    let(:blob_blame) { Gitlab::Git::Blob.blame($repository,$commit.id,$blob.path) }
    it('Gitlab::Git::Blob.blame'){ blob_blame.should be_kind_of Array }
    it{ blob_blame.first.first.should be_kind_of Gitlab::Git::Commit }
    if $for_right
      it{ blob_blame.first.last.first.should eq('# Contribute to GitLab') }
    end

  end

  if $for_right
    describe :find do
      context 'file in subdir' do
        let(:blob) { Gitlab::Git::Blob.find($repository, SeedRepo::Commit::ID, "files/ruby/popen.rb") }

        it { blob.id.should == SeedRepo::RubyBlob::ID }
        it { blob.name.should == SeedRepo::RubyBlob::NAME }
        it { blob.path.should == "files/ruby/popen.rb" }
        it { blob.commit_id.should == SeedRepo::Commit::ID }
        it { blob.data[0..10].should == SeedRepo::RubyBlob::CONTENT[0..10] }
        it { blob.size.should == 669 }
        it { blob.mode.should == "100644" }
      end

      context 'file in root' do
        let(:blob) { Gitlab::Git::Blob.find($repository, SeedRepo::Commit::ID, ".gitignore") }

        it { blob.id.should == "dfaa3f97ca337e20154a98ac9d0be76ddd1fcc82" }
        it { blob.name.should == ".gitignore" }
        it { blob.path.should == ".gitignore" }
        it { blob.commit_id.should == SeedRepo::Commit::ID }
        it { blob.data[0..10].should == "*.rbc\n*.sas" }
        it { blob.size.should == 241 }
        it { blob.mode.should == "100644" }
      end

      context 'non-exist file' do
        let(:blob) { Gitlab::Git::Blob.find($repository, SeedRepo::Commit::ID, "missing.rb") }

        it { blob.should be_nil }
      end

      context 'six submodule' do
        let(:blob) { Gitlab::Git::Blob.find($repository, SeedRepo::Commit::ID, 'six') }

        it { blob.id.should == '409f37c4f05865e4fb208c771485f211a22c4c2d' }
        it { blob.data.should == '' }
      end
    end

    describe 'encoding' do
      context 'file with russian text' do
        let(:blob) { Gitlab::Git::Blob.find($repository, SeedRepo::Commit::ID, "encoding/russian.rb") }

        it { blob.name.should == "russian.rb" }
        it { blob.data.lines.first.should == "Хороший файл" }
        it { blob.size.should == 23 }
        it { blob.mode.should == "100755" }
      end

      context 'file with Chinese text' do
        let(:blob) { Gitlab::Git::Blob.find($repository, SeedRepo::Commit::ID, "encoding/テスト.txt") }

        it { blob.name.should == "テスト.txt" }
        it { blob.data.should include("これはテスト") }
        it { blob.size.should == 340 }
        it { blob.mode.should == "100755" }
      end
    end

    describe 'mode' do
      context 'file regular' do
        let(:blob) do
          Gitlab::Git::Blob.find(
              $repository,
              'fa1b1e6c004a68b7d8763b86455da9e6b23e36d6',
              'files/ruby/regex.rb'
          )
        end

        it { blob.name.should == 'regex.rb' }
        it { blob.path.should == 'files/ruby/regex.rb' }
        it { blob.size.should == 1200 }
        it { blob.mode.should == "100644" }
      end

      context 'file binary' do
        let(:blob) do
          Gitlab::Git::Blob.find(
              $repository,
              'fa1b1e6c004a68b7d8763b86455da9e6b23e36d6',
              'files/executables/ls'
          )
        end

        it { blob.name.should == 'ls' }
        it { blob.path.should == 'files/executables/ls' }
        it { blob.size.should == 110080 }
        it { blob.mode.should == "100755" }
      end

      context 'file symlink to regular' do
        let(:blob) do
          Gitlab::Git::Blob.find(
              $repository,
              'fa1b1e6c004a68b7d8763b86455da9e6b23e36d6',
              'files/links/ruby-style-guide.md'
          )
        end

        it { blob.name.should == 'ruby-style-guide.md' }
        it { blob.path.should == 'files/links/ruby-style-guide.md' }
        it { blob.size.should == 31 }
        it { blob.mode.should == "120000" }
      end

      context 'file symlink to binary' do
        let(:blob) do
          Gitlab::Git::Blob.find(
              $repository,
              'fa1b1e6c004a68b7d8763b86455da9e6b23e36d6',
              'files/links/touch'
          )
        end

        it { blob.name.should == 'touch' }
        it { blob.path.should == 'files/links/touch' }
        it { blob.size.should == 20 }
        it { blob.mode.should == "120000" }
      end
    end
    
  else
    let(:blob) { Gitlab::Git::Blob.find($repository, $commit.id, $blob.path) }
    describe :find do
      context 'file in root' do
        it('Gitlab::Git::Blob.find'){ blob.should be_kind_of Gitlab::Git::Blob }
        it { blob.name.should == $blob.name }
        it { blob.path.should == $blob.path }
        it { blob.commit_id.should == $commit.id }
        it { blob.data.should be_kind_of String }
        it { blob.size.should > 0 }
        it { blob.data.lines.first.sub("\n",'').should == $blob.data.split("\n").first }
      end
      context 'non-exist file' do
        let(:null_blob) { Gitlab::Git::Blob.find($repository, $commit.id, "missing_#{Time.now.to_s}.rb") }
        it('Gitlab::Git::Blob.find(not-exist file)') { null_blob.should be_nil }
      end
    end
  end



  describe :raw do
    let(:raw_blob){Gitlab::Git::Blob.raw($repository, blob_id)}
    it('Gitlab::Git::Blob.raw'){raw_blob.id.should == blob_id }
    if $for_right
      it { raw_blob.data[0..10].should == "require \'fi" }
      it { raw_blob.size.should == 669 }
    end
  end

  describe :create do
    options = {
        file: {
            content: 'Lorem ipsum...',
            path: 'documents/story.txt'
        },
        author: {
            email: 'user@example.com',
            name: 'Test User',
            time: Time.now
        },
        committer: {
            email: 'user@example.com',
            name: 'Test User',
            time: Time.now
        },
        commit: {
            message: 'Wow such commit',
            branch: 'master'
        }
    }

    let(:commit_sha) { Gitlab::Git::Blob.commit($repository, options) }
    it('Gitlab::Git::Blob.commit'){ commit_sha.should_not be_nil }
    let(:commit) { $repository.lookup(commit_sha) }

    it  do
      # Commit message valid
      commit.message.should == 'Wow such commit'

      tree = commit.tree.to_a.find { |tree| tree[:name] == 'documents' }

      # Directory was created
      tree[:type].should == :tree

      # File was created
      $repository.lookup(tree[:oid]).first[:name].should == 'story.txt'
    end
  end

  context 'when remove file is not exists.' do
    before(:all) do
      options = {
          file: {
              content: 'Lorem ipsum...',
              path: 'documents/story2.txt'
          },
          author: {
              email: 'user@example.com',
              name: 'Test User',
              time: Time.now
          },
          committer: {
              email: 'user@example.com',
              name: 'Test User',
              time: Time.now
          },
          commit: {
              message: 'Wow such commit',
              branch: 'master'
          }
      }
      Gitlab::Git::Blob.commit($repository, options)
    end

    describe :remove do
      options2 = {
          file: {
              path: 'documents/story2.txt'
          },
          author: {
              email: 'user@example.com',
              name: 'Test User',
              time: Time.now
          },
          committer: {
              email: 'user@example.com',
              name: 'Test User',
              time: Time.now
          },
          commit: {
              message: 'Remove story2.txt',
              branch: 'master'
          }
      }

      let(:commit_sha) { Gitlab::Git::Blob.remove($repository, options2) }
      let(:commit) { $repository.lookup(commit_sha) }
      # it('Gitlab::Git::Blob.remove'){ commit_sha.should_not be_nil }

      it do
        # Commit message valid
        commit.message.should == 'Remove story2.txt'

        # File was removed
        commit.tree.to_a.any? do |tree|
          tree[:name] == 'story2.txt'
        end.should be_false
      end
    end
  end

end
