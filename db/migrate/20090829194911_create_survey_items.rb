class CreateSurveyItems < ActiveRecord::Migration
  def self.up
    create_table :survey_items do |t|
      t.integer :survey_page_id
      t.integer :question_id
      t.integer :sequence

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_items
  end
end
