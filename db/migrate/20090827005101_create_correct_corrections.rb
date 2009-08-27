class CreateCorrectCorrections < ActiveRecord::Migration
  def self.up
    create_table :correct_corrections do |t|
      t.integer :participant_id
      t.integer :round
      t.integer :correction_id

      t.timestamps
    end
  end

  def self.down
    drop_table :correct_corrections
  end
end
