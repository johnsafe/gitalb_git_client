module Gitlab
  module Git
    class Railtie < Rails::Railtie
      initializer 'gitlab_git.add_middleware' do |app|
        app.config.middleware.insert_before "Rack::Runtime", "Gitlab::Git::Middleware"
      end
    end
  end
end
