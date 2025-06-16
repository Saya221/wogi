class CreateBrands < ActiveRecord::Migration[7.2]
  def change
    create_table :brands, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :state, default: Brand.states[:active], null: false, index: true

      t.text :description
      t.string :country
      t.string :website_url

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
