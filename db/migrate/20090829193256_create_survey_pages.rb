class CreateSurveyPages < ActiveRecord::Migration
  def self.up
    create_table :survey_pages do |t|
      t.integer :survey_id
      t.integer :sequence
      t.integer :depends_on_question_id
      t.string :requires_answer

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_pages
  end
end
