class AddTwitterimgToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_img_url, :string
  end

  def self.down
    remove_column :users, :twitter_img_url
  end
end
