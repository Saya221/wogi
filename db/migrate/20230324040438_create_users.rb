class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email, null: false, index: {unique: true}
      t.string :password_encrypted, null: false
      t.string :type, index: true
      t.integer :state, default: User.states[:active], null: false, index: true
      t.decimal :payout_rate, precision: 10, scale: 2
      t.datetime :confirmed_at

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
