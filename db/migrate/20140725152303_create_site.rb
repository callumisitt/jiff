class CreateSite < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.string :url
      t.string :server_ref
      t.integer :server_id
    end
  end
end
