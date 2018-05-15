class CreateDividends < ActiveRecord::Migration[5.1]
  def change
    create_table :dividends do |t|
      t.string :symbol
      t.integer :year
      t.integer :month
      t.decimal :amount
      t.datetime :date

      t.timestamps
    end
  end
end
