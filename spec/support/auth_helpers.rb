module AuthHelpers
  # Sign a user in via the session-based login endpoint.
  # Used by request specs that hit authenticated routes.
  def login_as(user, password: "password")
    post login_path, params: { email: user.email, password: password }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
