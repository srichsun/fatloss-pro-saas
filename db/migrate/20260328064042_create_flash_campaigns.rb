class CreateFlashCampaigns < ActiveRecord::Migration[8.2]
  def change
    create_table :flash_campaigns do |t|
      t.references :tenant, null: false, foreign_key: true # Link each campaign to a specific tenant/coach for data isolation
      t.string :title
      t.integer :price
      t.integer :total_stock, default: 0     # Recommended default for total stock
      t.integer :remaining_stock, default: 0 # Set default to 0 as requested
      t.datetime :expired_at
      t.string :influencer_name

      t.timestamps
    end

    # Essential for high traffic: add a database-level check to ensure stock never goes below zero.
    # This acts as the final physical defense against overselling, even if there is a bug in the application logic.
    execute "ALTER TABLE flash_campaigns ADD CONSTRAINT stock_cannot_be_negative CHECK (remaining_stock >= 0);"
  end
end