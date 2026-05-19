# spec/requests/dashboards_spec.rb
require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:tenant) { Tenant.create!(name: "Gym", subdomain: "gym") }
  let(:user)   { User.create!(name: "Owner", email: "owner@test.com", password: "password", tenant: tenant) }

  it "returns http success when logged in" do
    post login_path, params: { email: user.email, password: 'password' }

    get dashboard_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Storefront Overview")
  end

  it "redirects to login when not authenticated" do
    get dashboard_path
    expect(response).to redirect_to(login_path)
  end
end
