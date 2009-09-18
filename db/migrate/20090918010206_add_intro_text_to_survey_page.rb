class AddIntroTextToSurveyPage < ActiveRecord::Migration
  def self.up
    add_column :survey_pages, :intro_text, :text
  end

  def self.down
    remove_column :survey_pages, :intro_text
  end
end
