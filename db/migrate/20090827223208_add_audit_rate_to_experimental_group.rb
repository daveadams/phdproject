class AddAuditRateToExperimentalGroup < ActiveRecord::Migration
  def self.up
    add_column :experimental_groups, :audit_rate, :decimal,
               :precision => 8, :scale => 4, :default => 0.0100
  end

  def self.down
    remove_column :experimental_groups, :audit_rate
  end
end
