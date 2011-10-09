class AddAuthCredentialsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :auth_token, :string
    add_column :users, :auth_secret, :string
    add_column :users, :description, :string
  end

  def self.down
    remove_column :users, :description
    remove_column :users, :auth_secret
    remove_column :users, :auth_token
  end
end
