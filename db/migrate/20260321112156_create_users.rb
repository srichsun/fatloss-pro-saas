class CreateUsers < ActiveRecord::Migration[8.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.integer :role
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
