class CreateTutorialTextGroups < ActiveRecord::Migration
  def self.up
    create_table :tutorial_text_groups do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :tutorial_text_groups
  end
end
