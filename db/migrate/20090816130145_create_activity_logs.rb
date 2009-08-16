class CreateActivityLogs < ActiveRecord::Migration
  def self.up
    create_table :activity_logs do |t|
      t.integer :participant_id
      t.string :event
      t.string :controller
      t.string :action
      t.text :details

      t.timestamps
    end
  end

  def self.down
    drop_table :activity_logs
  end
end
