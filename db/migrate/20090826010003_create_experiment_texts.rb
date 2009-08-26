class CreateExperimentTexts < ActiveRecord::Migration
  def self.up
    create_table :experiment_texts do |t|
      t.string :page_name
      t.string :text_key
      t.text :text
      t.integer :experimental_group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :experiment_texts
  end
end
