class CreateCorrections < ActiveRecord::Migration
  def self.up
    create_table :corrections do |t|
      t.integer :source_text_id
      t.string :error
      t.string :correction

      t.timestamps
    end
  end

  def self.down
    drop_table :corrections
  end
end
