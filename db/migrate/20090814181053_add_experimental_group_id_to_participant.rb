class AddExperimentalGroupIdToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :experimental_group_id, :integer
  end

  def self.down
    remove_column :participants, :experimental_group_id
  end
end
