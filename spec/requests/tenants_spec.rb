require 'rails_helper'

RSpec.describe "Tenant Isolation", type: :request do
  # Setup two different coach rooms
  let!(:coach_a) { Tenant.create!(name: "Coach A", subdomain: "coach-a") }
  let!(:coach_b) { Tenant.create!(name: "Coach B", subdomain: "coach-b") }

  describe "Accessing a specific tenant room" do
    it "allows access to the correct tenant room" do
      # Enter Coach A's room with correct ID
      get tenant_path(coach_a, tenant_id: coach_a.id)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Coach A")
    end

    it "prevents access when no tenant_id is provided" do
      # Try to enter a room without a tenant_id (should be kicked to root)
      get tenant_path(coach_a) 
      expect(response).to redirect_to(root_path)
    end
  end
end