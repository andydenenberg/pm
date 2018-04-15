class AddGroupToPortfolios < ActiveRecord::Migration[5.1]
  def change
    add_column :portfolios, :group_id, :integer
  end
end
