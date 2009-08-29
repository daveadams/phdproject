class DropPossibleAnswer < ActiveRecord::Migration
  def self.up
    drop_table :possible_answers
  end

  def self.down
  end
end
