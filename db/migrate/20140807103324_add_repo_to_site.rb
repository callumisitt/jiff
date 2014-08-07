class AddRepoToSite < ActiveRecord::Migration
  def change
    add_column :sites, :repo, :string
  end
end
