require "rails_helper"

# Signup creates the Tenant + first owner User in one transaction. The
# subdomain is auto-generated, so the only required input is the storefront
# name and account email/password/name.
RSpec.describe "Registrations", type: :request do
  let(:valid_params) do
    {
      tenant: { name: "Iron Gym" },
      user:   { name: "Dane", email: "dane@test.com", password: "password" }
    }
  end

  # --- Happy path ---

  it "renders the signup form" do
    get signup_path

    expect(response).to have_http_status(:success)
  end

  it "creates a tenant and an owner user, then redirects to dashboard" do
    expect {
      post signup_path, params: valid_params
    }.to change(Tenant, :count).by(1).and change(User, :count).by(1)

    expect(response).to redirect_to(dashboard_path)
  end

  it "auto-generates a subdomain for the new tenant" do
    post signup_path, params: valid_params

    expect(Tenant.last.subdomain).to be_present
    expect(Tenant.last.subdomain.length).to eq(8)
  end

  it "logs the new owner in (session populated)" do
    post signup_path, params: valid_params

    follow_redirect!
    expect(response).to have_http_status(:success)
    expect(response.body).to include("店家總覽")
  end

  # --- Fail path — invalid input ---

  it "re-renders new with 422 when tenant name is blank" do
    post signup_path, params: valid_params.deep_merge(tenant: { name: "" })

    expect(response).to have_http_status(:unprocessable_entity)
    expect(Tenant.count).to eq(0)
    expect(User.count).to eq(0)
  end

  it "re-renders new with 422 when user name is blank" do
    post signup_path, params: valid_params.deep_merge(user: { name: "" })

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "rolls back tenant creation when user validation fails" do
    expect {
      post signup_path, params: valid_params.deep_merge(user: { name: "" })
    }.not_to change(Tenant, :count)
  end
end
