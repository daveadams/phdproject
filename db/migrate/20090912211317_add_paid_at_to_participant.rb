class AddPaidAtToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :paid_at, :datetime
  end

  def self.down
    remove_column :participants, :paid_at
  end
end
