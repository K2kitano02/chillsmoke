# frozen_string_literal: true

class CreateUserPurchaseHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :user_purchase_histories do |t|
      t.references :user_wishlist, null: false, foreign_key: true, index: { unique: true }
      t.integer :amount, null: false
      t.datetime :purchased_at, null: false

      t.timestamps
    end
  end
end
