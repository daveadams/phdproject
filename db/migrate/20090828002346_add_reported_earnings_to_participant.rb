class AddReportedEarningsToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :reported_earnings, :text
  end

  def self.down
    remove_column :participants, :reported_earnings
  end
end
