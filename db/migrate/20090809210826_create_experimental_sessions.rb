class CreateExperimentalSessions < ActiveRecord::Migration
  def self.up
    create_table :experimental_sessions do |t|
      t.string :name
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :experiment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :experimental_sessions
  end
end
