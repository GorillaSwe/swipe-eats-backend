class ChangeUrlColumnTypeInPhotos < ActiveRecord::Migration[7.0]
  def change
    change_column :photos, :url, :text
  end
end