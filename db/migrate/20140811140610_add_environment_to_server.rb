class AddEnvironmentToServer < ActiveRecord::Migration
  def change
    add_column :servers, :environment, :string
  end
end
