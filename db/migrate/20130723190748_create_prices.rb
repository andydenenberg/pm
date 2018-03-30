class CreatePrices < ActiveRecord::Migration[5.1]
  def change
    create_table :prices do |t|
      t.string :sec_type
      t.string :symbol
      t.datetime :last_update
      t.decimal :change,  :precision => 10, :scale => 2
      t.decimal :strike,  :precision => 10, :scale => 2
      t.string :exp_date
      t.decimal :bid,  :precision => 10, :scale => 2
      t.decimal :ask,  :precision => 10, :scale => 2
      t.decimal :last_price,  :precision => 10, :scale => 2

      t.timestamps
    end
  end
end
