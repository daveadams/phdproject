class AddGambleChoicesToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :gamble0, :string
    add_column :participants, :gamble1, :string
    add_column :participants, :gamble2, :string
    add_column :participants, :gamble3, :string
    add_column :participants, :gamble4, :string
    add_column :participants, :gamble5, :string
    add_column :participants, :gamble6, :string
    add_column :participants, :gamble7, :string
    add_column :participants, :gamble8, :string
    add_column :participants, :gamble9, :string
  end

  def self.down
    remove_column :participants, :gamble9
    remove_column :participants, :gamble8
    remove_column :participants, :gamble7
    remove_column :participants, :gamble6
    remove_column :participants, :gamble5
    remove_column :participants, :gamble4
    remove_column :participants, :gamble3
    remove_column :participants, :gamble2
    remove_column :participants, :gamble1
    remove_column :participants, :gamble0
  end
end
