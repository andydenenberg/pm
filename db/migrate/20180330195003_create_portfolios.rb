class CreatePortfolios < ActiveRecord::Migration[5.1]
  def change
    create_table :portfolios do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.decimal :cash,   :precision => 10, :scale => 2

      t.timestamps
    end
  end
end
