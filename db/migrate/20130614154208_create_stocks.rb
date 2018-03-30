class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.string  :symbol
      t.string  :name
      t.integer :portfolio_id
      t.decimal :quantity,  :precision => 10, :scale => 2
      t.decimal :purchase_price,  :precision => 10, :scale => 2
      t.string  :purchase_date
      t.decimal :strike, :precision => 10, :scale => 2
      t.string  :expiration_date  
      t.string  :stock_option  
      
      t.timestamps
    end
  end
end
