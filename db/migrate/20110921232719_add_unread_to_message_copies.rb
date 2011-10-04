class AddUnreadToMessageCopies < ActiveRecord::Migration
  def self.up
    add_column :message_copies, :unread, :boolean, :default => true
  end

  def self.down
    remove_column :message_copies, :unread
  end
end
