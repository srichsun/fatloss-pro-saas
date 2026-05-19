require "rails_helper"

# ApplicationJob is currently an empty base class. This spec exists to
# ensure it loads cleanly — actual job behaviour is exercised through
# the mailer delivery jobs.
RSpec.describe ApplicationJob, type: :job do
  it "inherits from ActiveJob::Base" do
    expect(described_class.ancestors).to include(ActiveJob::Base)
  end
end
