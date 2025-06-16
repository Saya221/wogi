class CreateAccessibleProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :accessible_products, id: :uuid do |t|
      t.references :product, type: :uuid
      t.references :user, type: :uuid

      t.datetime :deleted_at
      t.timestamps
    end

    add_index :accessible_products, [:product_id, :user_id], unique: true
  end
end
