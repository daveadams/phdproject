class AddContextFieldsToCorrection < ActiveRecord::Migration
  def self.up
    add_column :corrections, :error_context, :string
    add_column :corrections, :correction_context, :string
  end

  def self.down
    remove_column :corrections, :correction_context
    remove_column :corrections, :error_context
  end
end
