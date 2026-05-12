# frozen_string_literal: true

class CreateUserWishlists < ActiveRecord::Migration[7.2]
  def change
    create_table :user_wishlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :price, null: false
      t.text :memo
      t.boolean :is_purchased, null: false, default: false

      t.timestamps
    end
  end
end
