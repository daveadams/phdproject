class UpdateParticipantDefaultRound < ActiveRecord::Migration
  def self.up
    change_column_default :participants, :round, 1
    change_column_default :experimental_sessions, :round, 1
  end

  def self.down
    change_column_default :experimental_sessions, :round, 0
    change_column_default :participants, :round, 0
  end
end
