class AddBoundaryLabelsToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :left_boundary, :string
    add_column :questions, :right_boundary, :string
  end

  def self.down
    remove_column :questions, :right_boundary
    remove_column :questions, :left_boundary
  end
end
