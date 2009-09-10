class AddWorkLoadTimeToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :work_load_time, :datetime
  end

  def self.down
    remove_column :participants, :work_load_time
  end
end
