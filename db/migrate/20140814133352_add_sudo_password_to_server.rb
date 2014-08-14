class AddSudoPasswordToServer < ActiveRecord::Migration
  def change
    add_column :servers, :password_digest, :string
  end
end
