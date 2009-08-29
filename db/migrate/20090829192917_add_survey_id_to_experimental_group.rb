class AddSurveyIdToExperimentalGroup < ActiveRecord::Migration
  def self.up
    add_column :experimental_groups, :survey_id, :integer
  end

  def self.down
    remove_column :experimental_groups, :survey_id
  end
end
