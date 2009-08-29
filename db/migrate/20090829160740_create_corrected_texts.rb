class CreateCorrectedTexts < ActiveRecord::Migration
  def self.up
    create_table :corrected_texts do |t|
      t.integer :round
      t.text :corrected_text

      t.timestamps
    end
  end

  def self.down
    drop_table :corrected_texts
  end
end
