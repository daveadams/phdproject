class AddIpTrackingToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :last_ip, :string
    add_column :participants, :all_ips, :text
  end

  def self.down
    remove_column :participants, :all_ips
    remove_column :participants, :last_ip
  end
end
