class AddTimeLimitToExperimentalGroup < ActiveRecord::Migration
  def self.up
    add_column :experimental_groups, :work_time_limit, :integer, :default => 120
  end

  def self.down
    remove_column :experimental_groups, :work_time_limit
  end
end
