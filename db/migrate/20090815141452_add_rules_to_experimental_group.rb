class AddRulesToExperimentalGroup < ActiveRecord::Migration
  def self.up
    add_column :experimental_groups, :earnings, :decimal, :precision => 8, :scale => 2, :default => 0.35
    add_column :experimental_groups, :tax_rate, :integer, :default => 20
    add_column :experimental_groups, :penalty_rate, :decimal, :precision => 8, :scale => 2, :default => 1.5
    add_column :experimental_groups, :rounds, :integer, :default => 20
  end

  def self.down
    remove_column :experimental_groups, :rounds
    remove_column :experimental_groups, :penalty_rate
    remove_column :experimental_groups, :tax_rate
    remove_column :experimental_groups, :earnings
  end
end
