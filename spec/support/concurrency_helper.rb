# Specs tagged with :concurrency spawn threads that each check out their
# own DB connection. The default transactional fixture wraps the whole test
# in a single transaction on one connection, which the spawned threads cannot
# see — so the seeded campaign would look like it does not exist.
#
# For tagged tests we disable the transactional wrap and clean up tables
# manually after the test runs.
RSpec.configure do |config|
  config.before(:each, :concurrency) do
    self.use_transactional_tests = false
  end

  config.after(:each, :concurrency) do
    FlashOrder.delete_all
    FlashCampaign.delete_all
    Tenant.delete_all
    self.use_transactional_tests = true
  end
end
