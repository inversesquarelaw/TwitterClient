class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :id => false do |t|
      t.string :twitter_user_id, :null => false
      t.string :screen_name, :null => false

      t.timestamps
    end

    add_index :users, :twitter_user_id, :unique => true
    add_index :users, :username, :unique => true
  end
end
