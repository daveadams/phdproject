class CreatePageOrders < ActiveRecord::Migration
  def self.up
    create_table :page_orders do |t|
      t.string :phase
      t.integer :experimental_group_id
      t.text :page_order

      t.timestamps
    end
  end

  def self.down
    drop_table :page_orders
  end
end
