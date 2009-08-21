class DropExperiment < ActiveRecord::Migration
  def self.up
    drop_table :experiments
    remove_column :experimental_sessions, :experiment_id
  end

  def self.down
  end
end
