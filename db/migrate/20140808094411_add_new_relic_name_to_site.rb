class AddNewRelicNameToSite < ActiveRecord::Migration
  def change
    add_column :sites, :new_relic_name, :string
  end
end
