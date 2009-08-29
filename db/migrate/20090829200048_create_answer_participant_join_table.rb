class CreateAnswerParticipantJoinTable < ActiveRecord::Migration
  def self.up
    create_table :answers_participants, :id => false do |t|
      t.integer :answer_id
      t.integer :participant_id
    end
  end

  def self.down
    drop_table :answers_participants
  end
end
