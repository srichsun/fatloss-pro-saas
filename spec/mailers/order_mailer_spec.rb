require "rails_helper"

# OrderMailer#confirmation_email is the only mailer in the app. It's the
# email a fan gets after a successful flash purchase; subject is dynamic
# (campaign title) and the recipient is the fan's submitted email.
RSpec.describe OrderMailer, type: :mailer do
  let(:campaign) { create(:flash_campaign, title: "Limited Drop") }
  let(:order)    { create(:flash_order, flash_campaign: campaign, name: "Alice", email: "alice@x.com") }

  # --- Happy path ---

  describe "#confirmation_email" do
    let(:mail) { described_class.confirmation_email(order) }

    it "sends to the fan's email address" do
      expect(mail.to).to eq([ "alice@x.com" ])
    end

    it "puts the campaign title in the subject" do
      expect(mail.subject).to include("Limited Drop")
    end

    # --- Isolation — subject pattern is stable ---

    it "uses the 搶購成功通知 marker so support can filter notifications" do
      expect(mail.subject).to include("搶購成功通知")
    end
  end
end
