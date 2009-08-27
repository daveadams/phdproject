class RenameTypeToTransactionType < ActiveRecord::Migration
  def self.up
    rename_column :cash_transactions, :type, :transaction_type
  end

  def self.down
    rename_column :cash_transactions, :transaction_type, :type
  end
end
