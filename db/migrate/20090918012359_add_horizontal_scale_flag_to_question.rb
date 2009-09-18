class AddHorizontalScaleFlagToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :horizontal_scale, :boolean, :default => false
  end

  def self.down
    remove_column :questions, :horizontal_scale
  end
end
