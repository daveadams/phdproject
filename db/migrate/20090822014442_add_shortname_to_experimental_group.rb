class AddShortnameToExperimentalGroup < ActiveRecord::Migration
  def self.up
    add_column :experimental_groups, :shortname, :string
  end

  def self.down
    remove_column :experimental_groups, :shortname
  end
end
