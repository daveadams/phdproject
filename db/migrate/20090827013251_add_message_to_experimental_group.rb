class AddMessageToExperimentalGroup < ActiveRecord::Migration
  def self.up
    add_column :experimental_groups, :message, :text
  end

  def self.down
    remove_column :experimental_groups, :message
  end
end
