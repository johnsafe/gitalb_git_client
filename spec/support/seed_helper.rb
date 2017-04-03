module SeedHelper
  #GITHUB_URL = "https://code.csdn.net/liuhq002/gitlab-git-test.git"
  GITHUB_URL = File.join(PRE_PATH, "../code_test/gitlab-git-test.git")
  def ensure_seeds
    if File.exists?(SUPPORT_PATH)
      FileUtils.rm_r(SUPPORT_PATH)
    end

    FileUtils.mkdir_p(SUPPORT_PATH)

    create_bare_seeds
    # create_normal_seeds
    # create_mutable_seeds
    create_bare_merge_seeds
  end

  def create_bare_seeds
    system(git_env, *%W(git clone --bare #{GITHUB_URL}), chdir: SUPPORT_PATH)
  end

  def create_normal_seeds
    system(git_env, *%W(git clone #{TEST_REPO_PATH} #{TEST_NORMAL_REPO_PATH}))
  end

  def create_mutable_seeds
    system(git_env, *%W(git clone #{TEST_REPO_PATH} #{TEST_MUTABLE_REPO_PATH}))
    system(git_env, *%w(git branch -t feature origin/feature),
           chdir: TEST_MUTABLE_REPO_PATH)
    system(git_env, *%W(git remote add expendable #{GITHUB_URL}),
           chdir: TEST_MUTABLE_REPO_PATH)
  end

  def create_bare_merge_seeds
    system(git_env, *%W(git clone --bare #{GITHUB_URL} merge.git), chdir: SUPPORT_PATH)
  end

  # Prevent developer git configurations from being persisted to test
  # repositories
  def git_env
    {'GIT_TEMPLATE_DIR' => ''}
  end
end
