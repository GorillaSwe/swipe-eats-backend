class CreateFollowRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :follow_relationships do |t|

      t.integer :follower_id, null: false
      t.integer :followed_id, null: false
      t.timestamps

    end
    
    add_index :follow_relationships, :follower_id
    add_index :follow_relationships, :followed_id
    add_index :follow_relationships, [:follower_id, :followed_id], unique: true
  end
end