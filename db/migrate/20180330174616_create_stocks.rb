class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.references :portfolio, foreign_key: true
      t.string :title
      t.text :body
      t.decimal :purchase_price,  :precision => 10, :scale => 2
      t.decimal :quantity,        :precision => 10, :scale => 2
      t.string :symbol
      t.string :name
      t.integer :portfolio_id
      t.string :purchase_date
      t.decimal :strike,          :precision => 10, :scale => 2
      t.string :expiration_date
      t.string :stock_option

      t.timestamps
    end
  end
end


