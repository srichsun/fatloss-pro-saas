class CreateTenants < ActiveRecord::Migration[8.2]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :subdomain

      t.timestamps
    end
  end
end
