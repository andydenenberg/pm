class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.integer :portfolio_id
      t.decimal :purchase_price,  :precision => 10, :scale => 2
      t.decimal :quantity,        :precision => 10, :scale => 2
      t.string :symbol
      t.string :name
      t.string :purchase_date
      t.decimal :strike,          :precision => 10, :scale => 2
      t.decimal :price
      t.string :as_of
      t.string :expiration_date
      t.string :stock_option

      t.timestamps
    end
  end
end


