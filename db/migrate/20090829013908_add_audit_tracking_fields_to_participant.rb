class AddAuditTrackingFieldsToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :to_be_audited, :boolean, :default => false
    add_column :participants, :audit_completed, :boolean, :default => false
  end

  def self.down
    remove_column :participants, :audit_completed
    remove_column :participants, :to_be_audited
  end
end
