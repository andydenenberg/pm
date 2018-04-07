class AddIndexToHistory < ActiveRecord::Migration[5.1]
  def change
    add_index :histories, :snapshot_date
  end
end
