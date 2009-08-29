class AddSequenceToAnswer < ActiveRecord::Migration
  def self.up
    add_column :answers, :sequence, :integer
  end

  def self.down
    remove_column :answers, :sequence
  end
end
