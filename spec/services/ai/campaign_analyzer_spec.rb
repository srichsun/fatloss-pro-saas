require "rails_helper"
require "ostruct"

# Ai::CampaignAnalyzer asks Claude for 3 actionable insights about one
# campaign. The spec stubs the SDK so it runs offline and deterministically.
RSpec.describe Ai::CampaignAnalyzer do
  let(:campaign) { create(:flash_campaign, total_stock: 100, remaining_stock: 22) }

  def stub_anthropic(text: "- 售完率 78%，建議延長截止", raise: nil)
    fake_text     = OpenStruct.new(text: text)
    fake_response = OpenStruct.new(content: [ fake_text ])
    fake_messages = double("messages")

    if raise
      allow(fake_messages).to receive(:create).and_raise(raise)
    else
      allow(fake_messages).to receive(:create).and_return(fake_response)
    end

    allow(Anthropic::Client).to receive(:new).and_return(double("client", messages: fake_messages))
  end

  before { ENV["ANTHROPIC_API_KEY"] = "test-key" }
  after  { ENV.delete("ANTHROPIC_API_KEY") }

  # --- Happy path ---

  it "returns ok? true with the generated insights" do
    stub_anthropic(text: "- 不錯！\n- 加碼")

    result = described_class.new(campaign: campaign).call

    expect(result).to be_ok
    expect(result.insights).to include("加碼")
  end

  it "trims whitespace around the result text" do
    stub_anthropic(text: "  - 內容  \n")

    expect(described_class.new(campaign: campaign).call.insights).to eq("- 內容")
  end

  # --- Edge — empty orders ---

  it "still calls the API when the campaign has zero orders" do
    empty_campaign = create(:flash_campaign, total_stock: 10, remaining_stock: 10)
    stub_anthropic(text: "- 還沒有訂單，建議用 IG 限動推廣")

    expect(described_class.new(campaign: empty_campaign).call).to be_ok
  end

  # --- Edge — multi-order duration + hour distribution branches ---

  it "computes duration and hour bucket when campaign has multiple orders" do
    create(:flash_order, flash_campaign: campaign, created_at: 30.minutes.ago)
    create(:flash_order, flash_campaign: campaign, created_at: 5.minutes.ago)
    stub_anthropic(text: "- 平均 0.5 筆/分")

    expect(described_class.new(campaign: campaign).call).to be_ok
  end

  it "marks the campaign as expired in the prompt when expired_at is past" do
    expired_campaign = create(:flash_campaign, :expired)
    stub_anthropic(text: "- 活動結束")

    expect(described_class.new(campaign: expired_campaign).call).to be_ok
  end

  it "handles a zero-total-stock campaign without divide-by-zero" do
    zero_stock = build(:flash_campaign, total_stock: 0, remaining_stock: 0)
    zero_stock.save!(validate: false)
    stub_anthropic(text: "- 沒庫存")

    expect(described_class.new(campaign: zero_stock).call).to be_ok
  end

  # --- Fail path — upstream error ---

  it "returns a friendly error message when a non-retriable error throws" do
    stub_anthropic(raise: StandardError.new("config bug"))

    result = described_class.new(campaign: campaign).call

    expect(result).not_to be_ok
    expect(result.error).to include("AI 服務暫時無法使用")
  end

  # --- Retry behaviour ---
  #
  # Anthropic API occasionally returns 529 overloaded. Retry with
  # exponential backoff to smooth over transients without bothering
  # the user.
  describe "retry on transient errors" do
    # Build a fake retriable error class that matches one of the names
    # the analyzer treats as retriable. Avoids relying on the real gem
    # internals in tests.
    let(:transient) do
      stub_const("Anthropic::Errors::InternalServerError", Class.new(StandardError))
      Anthropic::Errors::InternalServerError.new("Overloaded")
    end

    let(:fake_text)     { OpenStruct.new(text: "- 成功") }
    let(:fake_response) { OpenStruct.new(content: [ fake_text ]) }
    let(:fake_messages) { double("messages") }

    before do
      # Skip the actual sleep so the test runs fast.
      allow_any_instance_of(described_class).to receive(:sleep)
      allow(Anthropic::Client).to receive(:new).and_return(double("client", messages: fake_messages))
    end

    it "retries up to MAX_ATTEMPTS-1 times then surfaces the error" do
      expect(fake_messages).to receive(:create)
        .exactly(described_class::MAX_ATTEMPTS).times
        .and_raise(transient)

      result = described_class.new(campaign: campaign).call

      expect(result).not_to be_ok
      expect(result.error).to include("AI 服務暫時無法使用")
    end

    it "returns success when a retry eventually works" do
      call_count = 0
      allow(fake_messages).to receive(:create) do
        call_count += 1
        raise transient if call_count < 2
        fake_response
      end

      result = described_class.new(campaign: campaign).call

      expect(result).to be_ok
      expect(result.insights).to eq("- 成功")
      expect(call_count).to eq(2)
    end

    it "does NOT retry on non-retriable errors" do
      expect(fake_messages).to receive(:create)
        .once
        .and_raise(StandardError.new("auth bad"))

      described_class.new(campaign: campaign).call
    end
  end
end
