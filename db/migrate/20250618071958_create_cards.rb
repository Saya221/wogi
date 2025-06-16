class CreateCards < ActiveRecord::Migration[7.2]
  def change
    create_table :cards, id: :uuid do |t|
      t.integer :state, default: Card.states[:issued], null: false, index: true
      t.references :user, type: :uuid
      t.references :product, type: :uuid

      t.string :activation_code, index: { unique: true }
      t.string :pin_code

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
