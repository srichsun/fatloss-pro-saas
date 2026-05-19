require "rails_helper"

# /flash_campaigns is the influencer-only management area. All actions
# require login. The show action is also the IDOR-resistance line of defence:
# campaigns are looked up through current_user.tenant.flash_campaigns so a
# tenant cannot view another tenant's campaign even by guessing the id.
RSpec.describe "Flash Campaigns", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user)   { create(:user, tenant: tenant) }

  # --- Happy path ---

  describe "GET /flash_campaigns" do
    it "lists campaigns belonging to the current tenant" do
      create(:flash_campaign, tenant: tenant, title: "Mine")
      login_as(user)

      get flash_campaigns_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Mine")
    end
  end

  describe "GET /flash_campaigns/new" do
    it "renders the create form" do
      login_as(user)

      get new_flash_campaign_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /flash_campaigns" do
    let(:valid_attrs) do
      {
        flash_campaign: {
          title: "Limited Tee",
          price: 990,
          total_stock: 100,
          expired_at: 1.hour.from_now
        }
      }
    end

    it "creates a campaign and syncs remaining_stock with total_stock" do
      login_as(user)

      expect {
        post flash_campaigns_path, params: valid_attrs
      }.to change(FlashCampaign, :count).by(1)

      campaign = FlashCampaign.last
      expect(campaign.remaining_stock).to eq(100)
      expect(response).to redirect_to(flash_campaigns_path)
    end

    # --- Fail path — invalid input ---

    it "re-renders new with 422 when title is missing" do
      login_as(user)

      post flash_campaigns_path, params: {
        flash_campaign: { price: 100, total_stock: 1, expired_at: 1.hour.from_now }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /flash_campaigns/:id" do
    let(:my_campaign) { create(:flash_campaign, tenant: tenant, title: "Mine") }

    # --- Happy path ---

    it "shows campaign details to its owner" do
      login_as(user)

      get flash_campaign_path(my_campaign)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Mine")
      expect(response.body).to include("/c/#{my_campaign.id}") # public URL surfaced
    end

    it "renders '尚無訂單' when the campaign has no orders" do
      login_as(user)

      get flash_campaign_path(my_campaign)

      expect(response.body).to include("尚無訂單")
    end

    it "lists recent fan orders when they exist" do
      create(:flash_order, flash_campaign: my_campaign, name: "Fan A", email: "a@x.com")
      login_as(user)

      get flash_campaign_path(my_campaign)

      expect(response.body).to include("Fan A")
      expect(response.body).to include("a@x.com")
    end

    # --- Isolation — IDOR-resistance ---

    it "responds with 404 when another tenant tries to view this campaign" do
      other_tenant = create(:tenant)
      other_user   = create(:user, tenant: other_tenant)
      login_as(other_user)

      get flash_campaign_path(my_campaign)

      expect(response).to have_http_status(:not_found)
    end
  end

  # --- Fail path — unauthenticated access ---

  describe "auth gate" do
    it "redirects to login when index is requested unauthenticated" do
      get flash_campaigns_path
      expect(response).to redirect_to(login_path)
    end

    it "redirects to login when show is requested unauthenticated" do
      campaign = create(:flash_campaign)
      get flash_campaign_path(campaign)
      expect(response).to redirect_to(login_path)
    end

    it "redirects to login when create is requested unauthenticated" do
      post flash_campaigns_path, params: { flash_campaign: { title: "X" } }
      expect(response).to redirect_to(login_path)
    end
  end
end
