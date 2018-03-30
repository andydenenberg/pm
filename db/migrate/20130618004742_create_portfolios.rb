class CreatePortfolios < ActiveRecord::Migration[5.1]
  def change
    create_table :portfolios do |t|
      t.string :name
      t.integer :user_id
      t.integer :portfolio_id
      t.decimal :cash,  :precision => 10, :scale => 2

      t.timestamps
    end
  end
end
