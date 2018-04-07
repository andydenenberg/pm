class AddChangeToStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :change, :decimal
  end
end
