# Libraries
require 'ostruct'
require 'fileutils'
require 'redis'
require 'settingslogic'
require 'linguist'
require 'active_support/core_ext/hash/keys'
require 'gitlab_git/commit_stats'
require 'drb'

#drb 
require_relative "drb/drb_client"

# Setings
require_relative "gitlab_git_client/settings"

# Gitlab::Git
require_relative "gitlab_git_client/encoding_helper"
require_relative "gitlab_git_client/client_methods"
require_relative "gitlab_git_client/ref"
require_relative "gitlab_git_client/tree"
require_relative "gitlab_git_client/compare"
require_relative "gitlab_git_client/diff"
require_relative "gitlab_git_client/repository"
require_relative "gitlab_git_client/branch"
require_relative "gitlab_git_client/tag"
require_relative "gitlab_git_client/blob"
require_relative "gitlab_git_client/blob_snippet"
require_relative "gitlab_git_client/blame"
require_relative "gitlab_git_client/commit"
require_relative "gitlab_git_client/submodule"
require_relative "gitlab_git_client/merge_repo"
require_relative "gitlab_git_client/online_edit"
require_relative "gitlab_git_client/cmd"

#Client

require_relative "gitlab_git_client/client"
require_relative "gitlab_git_client/middleware"
require_relative "gitlab_git_client/railtie" if defined?(Rails::Railtie)

#Start clent
Gitlab::Git::Client.start_client
