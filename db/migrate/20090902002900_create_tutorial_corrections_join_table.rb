class CreateTutorialCorrectionsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :tutorial_corrections, :id => false do |t|
      t.integer :correction_id
      t.integer :participant_id
    end
  end

  def self.down
    drop_table :tutorial_corrections
  end
end
