class CreateSysconfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :sysconfigs do |t|
      t.integer :ytd_max
      t.integer :ytd_min
      t.integer :start_max
      t.integer :start_min

      t.timestamps
    end
  end
end
