class AddFitbFieldsToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :fill_in_the_blank, :boolean, :default => false
    add_column :questions, :minimum, :integer, :default => 0
    add_column :questions, :maximum, :integer, :default => 100
  end

  def self.down
    remove_column :questions, :maximum
    remove_column :questions, :minimum
    remove_column :questions, :fill_in_the_blank
  end
end
