class CreatePortfolios < ActiveRecord::Migration[5.1]
  def change
    create_table :portfolios do |t|
      t.integer :user_id
      t.string :name
      t.decimal :cash,   :precision => 10, :scale => 2

      t.timestamps
    end
  end
end
