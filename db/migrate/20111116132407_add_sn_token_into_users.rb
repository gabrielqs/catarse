class AddSnTokenIntoUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sn_token, :text
  end

  def self.down
    remove_column :users, :sn_token, :text
  end
end
