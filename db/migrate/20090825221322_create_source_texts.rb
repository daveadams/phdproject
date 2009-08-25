class CreateSourceTexts < ActiveRecord::Migration
  def self.up
    create_table :source_texts do |t|
      t.text :errored_text
      t.integer :round

      t.timestamps
    end
  end

  def self.down
    drop_table :source_texts
  end
end
