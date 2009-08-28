class AddAuditStatusFieldsToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :last_check, :integer, :default => 0
    add_column :participants, :audited, :boolean, :default => false
  end

  def self.down
    remove_column :participants, :audited
    remove_column :participants, :last_check
  end
end
