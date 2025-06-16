class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name, null: false
      t.integer :state, default: Product.states[:active], null: false, index: true
      t.references :brand, type: :uuid

      t.text :description
      t.decimal :price, precision: 10, scale: 2

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
