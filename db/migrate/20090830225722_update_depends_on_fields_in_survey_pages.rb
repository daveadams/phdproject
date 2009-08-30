class UpdateDependsOnFieldsInSurveyPages < ActiveRecord::Migration
  def self.up
    remove_column :survey_pages, :depends_on_question_id
    remove_column :survey_pages, :requires_answer
    add_column :survey_pages, :depends_on_answer_id, :integer
  end

  def self.down
    remove_column :survey_pages, :depends_on_answer_id
    add_column :survey_pages, :depends_on_question_id, :integer
    add_column :survey_pages, :requires_answer, :string
  end
end
