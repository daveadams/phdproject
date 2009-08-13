class CreateTutorialTexts < ActiveRecord::Migration
  def self.up
    create_table :tutorial_texts do |t|
      t.string :group_name
      t.string :page_name
      t.string :text_key
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :tutorial_texts
  end
end
