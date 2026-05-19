require "rails_helper"

# /c/:id is the public landing page fans hit from an IG story link.
# It must render for anonymous visitors and stay fast — the controller is
# intentionally minimal (one finder + render).
RSpec.describe "Campaign Sales", type: :request do
  # --- Happy path ---

  it "renders the public landing page for an anonymous visitor" do
    campaign = create(:flash_campaign, title: "Limited Drop")

    get "/c/#{campaign.id}"

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Limited Drop")
  end

  # --- Fail path ---

  it "responds with 404 when the campaign id does not exist" do
    get "/c/0"
    expect(response).to have_http_status(:not_found)
  end

  # --- Isolation ---

  it "renders without requiring login (no auth redirect)" do
    campaign = create(:flash_campaign)

    get "/c/#{campaign.id}"

    expect(response).not_to redirect_to(login_path)
  end
end
