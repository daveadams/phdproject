class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.string :participant_number
      t.datetime :first_login
      t.datetime :last_access
      t.boolean :is_active
      t.integer :experimental_session_id

      t.timestamps
    end
  end

  def self.down
    drop_table :participants
  end
end
