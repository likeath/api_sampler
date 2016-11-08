# frozen_string_literal: true
module ApiSampler
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      ApiSampler::Worker.current.handle_request(env)
      @app.call(env).tap do |response|
        ApiSampler::Worker.current.handle_response(*response)
      end
    end
  end
end
