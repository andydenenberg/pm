class CreateHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :histories do |t|
      t.decimal :cash,  :precision => 10, :scale => 2
      t.decimal :stocks,  :precision => 10, :scale => 2
      t.integer :stocks_count
      t.decimal :options,  :precision => 10, :scale => 2
      t.integer :options_count
      t.decimal :total,  :precision => 10, :scale => 2
      t.datetime :snapshot_date
      t.references :portfolio

      t.timestamps
    end
#    add_index :histories, :portfolio_id
  end
end
