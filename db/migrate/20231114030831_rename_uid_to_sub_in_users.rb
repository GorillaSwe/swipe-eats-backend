class RenameUidToSubInUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :uid, :sub
  end
end