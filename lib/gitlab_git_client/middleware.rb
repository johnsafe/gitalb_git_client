require 'digest/md5'
module Gitlab
  module Git
    class Middleware
      class << self 
        def set_web_request_id(id)
          @web_request_id = id
        end

        def get_web_request_id
          @web_request_id
        end
      end

      def initialize(app)
        @app = app 
      end 

      def call(env)
        web_request_id = env['HTTP_HEROKU_REQUEST_ID'] || Digest::MD5.hexdigest(Time.now.to_f.to_s + $PID.to_s)
        Gitlab::Git::Middleware.set_web_request_id(web_request_id)

        @app.call(env)
      end
    end
  end
end
