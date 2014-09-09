class AddEnvironmentPathsToServer < ActiveRecord::Migration
  def change
    add_column :servers, :environment_paths, :text
  end
end
