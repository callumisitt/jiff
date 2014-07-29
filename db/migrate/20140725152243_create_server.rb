class CreateServer < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.string :address
      t.string :user
    end
  end
end
