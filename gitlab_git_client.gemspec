Gem::Specification.new do |s|
  s.name        = 'gitlab_git_client'
  s.version     = `cat VERSION`
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "Gitlab::Git client"
  s.description = "a clent for gitlab_git by csdn"
  s.authors     = ["Liuhq", "Yanlp", "Lishh"]
  s.email       = 'codesupport@csdn.net'
  s.license     = 'MIT'
  s.files       = `git ls-files lib/`.split("\n") << 'VERSION'
  s.homepage    = 'https://code.csdn.net/huawei_code/gitlab_git_client.git'

  s.add_dependency("gitlab-linguist", "~> 3.0")
  s.add_dependency("activesupport", "~> 3.2.11")
  s.add_dependency("rchardet19", "~> 1.3")
  s.add_dependency("redis", "~> 3.2")
  s.add_dependency("redis-store", "~> 1.1.4")
  s.add_dependency("github-markup", "~> 0.7.4")
  s.add_dependency("github-markdown", "~> 0.5.5")
  s.add_dependency('nokogiri', '~> 1.6.6.2')
  s.add_dependency('settingslogic', '~> 2.0.9')
end
