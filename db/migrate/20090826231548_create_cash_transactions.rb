class CreateCashTransactions < ActiveRecord::Migration
  def self.up
    create_table :cash_transactions do |t|
      t.integer :participant_id
      t.integer :round
      t.string :type
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :cash_transactions
  end
end
