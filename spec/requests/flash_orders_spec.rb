require "rails_helper"

# The /c/:id/flash_orders endpoint is the high-concurrency hot path:
# anonymous fans POST here at the same instant a drop opens. The controller
# wraps the work in a transaction + pessimistic lock to prevent oversell.
# These specs exercise every branch in FlashOrdersController#create.
RSpec.describe "Flash Orders", type: :request do
  let(:campaign) { create(:flash_campaign) }
  let(:valid_params) do
    { flash_order: { name: "Fan A", email: "fan@test.com", phone: "0900000000" } }
  end

  def post_order(campaign_id: campaign.id, params: valid_params)
    post "/c/#{campaign_id}/flash_orders", params: params
  end

  # --- Happy path ---

  it "creates a flash order and redirects back to the public page" do
    expect {
      post_order
    }.to change(FlashOrder, :count).by(1)

    expect(response).to redirect_to("/c/#{campaign.id}")
    expect(flash[:notice]).to match(/搶購成功/)
  end

  it "decrements remaining_stock by exactly one on success" do
    expect {
      post_order
    }.to change { campaign.reload.remaining_stock }.by(-1)
  end

  it "enqueues a confirmation email after a successful order" do
    expect {
      post_order
    }.to have_enqueued_mail(OrderMailer, :confirmation_email)
  end

  it "persists the submitted name, email, and phone on the order" do
    post_order(params: { flash_order: { name: "Alice", email: "alice@x.com", phone: "0911" } })

    order = FlashOrder.last
    expect(order.name).to eq("Alice")
    expect(order.email).to eq("alice@x.com")
    expect(order.phone).to eq("0911")
  end

  # --- Fail path — invalid campaign state ---

  it "rejects the order with an alert when the campaign has expired" do
    expired = create(:flash_campaign, :expired)

    expect {
      post_order(campaign_id: expired.id)
    }.not_to change(FlashOrder, :count)

    expect(response).to redirect_to("/c/#{expired.id}")
    expect(flash[:alert]).to match(/結束/)
  end

  it "rejects the order with sold-out alert when remaining_stock is zero" do
    sold_out = create(:flash_campaign, :sold_out)

    expect {
      post_order(campaign_id: sold_out.id)
    }.not_to change(FlashOrder, :count)

    expect(response).to redirect_to("/c/#{sold_out.id}")
    expect(flash[:alert]).to match(/售完/)
  end

  it "does NOT enqueue email when the campaign is sold out" do
    sold_out = create(:flash_campaign, :sold_out)

    expect {
      post_order(campaign_id: sold_out.id)
    }.not_to have_enqueued_mail(OrderMailer, :confirmation_email)
  end

  # --- Fail path — invalid request input ---

  it "rolls back and surfaces validation errors when email is missing" do
    invalid = { flash_order: { name: "No Email", phone: "0900" } }

    expect {
      post_order(params: invalid)
    }.not_to change(FlashOrder, :count)

    expect(response).to redirect_to("/c/#{campaign.id}")
    expect(flash[:alert]).to be_present
  end

  it "rolls back stock decrement when the order fails validation" do
    invalid = { flash_order: { name: "No Email", phone: "0900" } }

    expect {
      post_order(params: invalid)
    }.not_to change { campaign.reload.remaining_stock }
  end

  it "redirects to root with alert when the campaign id does not exist" do
    post_order(campaign_id: 0)

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to match(/找不到/)
  end

  # --- Fail path — unexpected runtime error ---

  it "swallows unexpected errors and redirects with a generic alert" do
    # Force the lock! call to raise a non-RecordNotFound error so the
    # controller's rescue => e branch is exercised.
    allow_any_instance_of(FlashCampaign).to receive(:lock!).and_raise("boom")

    post_order

    expect(response).to redirect_to("/c/#{campaign.id}")
    expect(flash[:alert]).to match(/錯誤/)
  end

  # --- Edge / Boundary ---

  it "allows the order when remaining_stock is exactly one (last unit)" do
    last_unit = create(:flash_campaign, :last_unit)

    expect {
      post_order(campaign_id: last_unit.id)
    }.to change(FlashOrder, :count).by(1)

    expect(last_unit.reload.remaining_stock).to eq(0)
  end

  it "rejects the next order on a campaign that just drained to zero" do
    last_unit = create(:flash_campaign, :last_unit)
    post_order(campaign_id: last_unit.id) # drains it

    expect {
      post_order(campaign_id: last_unit.id, params: {
        flash_order: { name: "Late", email: "late@test.com", phone: "0911" }
      })
    }.not_to change(FlashOrder, :count)

    expect(flash[:alert]).to match(/售完/)
  end

  # --- Isolation — pessimistic lock prevents oversell ---
  #
  # Spawn many threads simultaneously POSTing against a 5-unit campaign.
  # Without SELECT ... FOR UPDATE this would oversell. With it, exactly
  # 5 succeed; the rest see "sold out". This is the demo's signature claim.
  it "never oversells under concurrent purchase attempts", :concurrency do
    pool_size = 20
    stock     = 5
    campaign  = create(:flash_campaign, total_stock: stock, remaining_stock: stock)

    threads = pool_size.times.map do |i|
      Thread.new do
        post "/c/#{campaign.id}/flash_orders", params: {
          flash_order: { name: "Fan #{i}", email: "fan#{i}@test.com", phone: "0900" }
        }
      ensure
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
    threads.each(&:join)

    campaign.reload
    expect(campaign.remaining_stock).to eq(0)
    expect(campaign.flash_orders.count).to eq(stock)
  end
end
