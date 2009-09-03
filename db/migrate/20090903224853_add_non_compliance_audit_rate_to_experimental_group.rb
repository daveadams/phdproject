class AddNonComplianceAuditRateToExperimentalGroup < ActiveRecord::Migration
  def self.up
    add_column(:experimental_groups, :noncompliance_audit_rate, :decimal,
               :precision => 8, :scale => 4, :default => 0.0200)
  end

  def self.down
    remove_column :experimental_groups, :noncompliance_audit_rate
  end
end
