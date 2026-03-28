class CreateFlashOrders < ActiveRecord::Migration[8.2]
  def change
    create_table :flash_orders do |t|
      # Link each order to a specific flash sale campaign
      t.references :flash_campaign, null: false, foreign_key: true
      
      # Minimalist fields for faster checkout conversion
      t.string :email, null: false
      t.string :name
      t.string :phone
      
      # Tracking order status (e.g., pending, paid, cancelled)
      t.string :status, default: 'pending'

      t.timestamps
    end

    # Add an index on email to quickly look up a fan's order history if needed
    add_index :flash_orders, :email
  end
end