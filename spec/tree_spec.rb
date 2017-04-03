require "spec_helper"

describe Gitlab::Git::Tree do
  context :repo do
    before(:all) do
      @tree = Gitlab::Git::Tree.where($repository, $commit.id)
      @dir = @tree.select(&:dir?).first
      @dir_path = @dir.contents.first.path
    end

    # let(:repository) { Gitlab::Git::Repository.new(TEST_REPO_PATH) }
    # let(:tree) { Gitlab::Git::Tree.where(repository, SeedRepo::Commit::ID) }
    # let(:blob) { Gitlab::Git::Tree.content_by_path(repository, '8bade7db1ce9b7d08cce1a0ccaa0ebadfb2b7c41', 'README.md')}
    # let(:contents) { Gitlab::Git::Tree.tree_contents(repository, '8bade7db1ce9b7d08cce1a0ccaa0ebadfb2b7c41')}
    #
    # it { blob.should be_kind_of Gitlab::Git::Blob }
    # it { blob.name.should == 'README.md' }

    it('Gitlab::Git::Tree.where'){Gitlab::Git::Tree.where($repository, $commit.id).should be_kind_of Array}
    it { @tree.should be_kind_of Array }
    it { @tree.empty?.should be_false }
    if $for_right
      it { @tree.select(&:dir?).size.should == 2 }
      it { @tree.select(&:file?).size.should == 10 }
      it { @tree.select(&:submodule?).size.should == 2 }

      describe :readme do
        let(:file) { @tree.select(&:readme?).first }

        it { file.should be_kind_of Gitlab::Git::Tree }
        it { file.name.should == 'README.md' }
      end

      describe :contributing do
        let(:file) { @tree.select(&:contributing?).first }

        it { file.should be_kind_of Gitlab::Git::Tree }
        it { file.name.should == 'CONTRIBUTING.md' }
      end

      describe :submodule do
        let(:submodule) { @tree.select(&:submodule?).first }

        it { submodule.should be_kind_of Gitlab::Git::Tree }
        it { submodule.id.should == '79bceae69cb5750d6567b223597999bfa91cb3b9' }
        it { submodule.commit_id.should == '570e7b2abdd848b95f2f578043fc23bd6f6fd24d' }
        it { submodule.name.should == 'gitlab-shell' }
      end
    end

    describe :dir do
      it { @dir.should be_kind_of Gitlab::Git::Tree }
      it { @dir.commit_id.should == $commit.id }
      if $for_right
        it { @dir.id.should == '3c122d2b7830eca25235131070602575cf8b41a1' }
        it { @dir.commit_id.should == SeedRepo::Commit::ID }
        it { @dir.name.should == 'encoding' }
        it { @dir.path.should == 'encoding' }
        context :subdir do
          let(:subdir) { Gitlab::Git::Tree.where($repository, SeedRepo::Commit::ID, 'files').first }

          it { subdir.should be_kind_of Gitlab::Git::Tree }
          it { subdir.id.should == 'a1e8f8d745cc87e3a9248358d9352bb7f9a0aeba' }
          it { subdir.commit_id.should == SeedRepo::Commit::ID }
          it { subdir.name.should == 'html' }
          it { subdir.path.should == 'files/html' }
        end

        context :subdir_file do
          let(:subdir_file) { Gitlab::Git::Tree.where($repository, SeedRepo::Commit::ID, 'files/ruby').first }

          it { subdir_file.should be_kind_of Gitlab::Git::Tree }
          it { subdir_file.id.should == '7e3e39ebb9b2bf433b4ad17313770fbe4051649c' }
          it { subdir_file.commit_id.should == SeedRepo::Commit::ID }
          it { subdir_file.name.should == 'popen.rb' }
          it { subdir_file.path.should == 'files/ruby/popen.rb' }
        end
      end
    end
    describe :tree_id do
      let(:tree_id) { Gitlab::Git::Tree.find_id_by_path($repository, @dir.root_id,@dir_path) }
      it('Gitlab::Git::Tree.find_id_by_path'){[true,false].should include tree_id.nil?}
      let(:tree1) { $repository.lookup(tree_id) }

      context 'when tree_id is not nil' do
        it do
          if tree_id
            tree1.oid.should==tree_id
            tree1.type.should==:tree
          end
        end
      end
    end

    describe :contents do
      let(:contents){@dir.contents}
      it('tree.contents') { contents.should be_kind_of Array}
      it { contents.should have_at_least(1).items }
      #each should be kind of tree or blob
      it do
        contents.each do |c|
          [Gitlab::Git::Blob,Gitlab::Git::Tree,Gitlab::Git::Submodule].should include c.class
        end
      end
    end

    describe :all_blob_names do
      let(:all_blob_names){@dir.all_blob_names($repository)}
      it('tree.all_blob_names'){ all_blob_names.should be_kind_of Array}
      it { all_blob_names.should include 'feature-1.txt' } if $for_right
    end

    describe :file do
      let(:file) { @tree.select(&:file?).first }

      it { file.should be_kind_of Gitlab::Git::Tree }
      it { file.commit_id.should == $commit.id }
      if $for_right
        it do
          file.id.should == 'dfaa3f97ca337e20154a98ac9d0be76ddd1fcc82'
          file.name.should == '.gitignore'
        end
      end
    end

    describe :trees do
      let(:ts) { @dir.trees }
      it('tree.trees'){ ts.should be_kind_of Array }
      #each should be kind of tree
      it do
        ts.each do |c|
          c.should be_kind_of Gitlab::Git::Tree
        end
      end
    end

    describe :blobs do
      let(:bs) { @dir.blobs }
      it('tree.blobs'){ bs.should be_kind_of Array }
      #each should be kind of blob
      it do
        bs.each do |b|
          b.should be_kind_of Gitlab::Git::Blob
        end
      end
    end
  end
end