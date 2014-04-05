class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.belongs_to :argument
      t.text       :code
      t.integer    :played_times
    end
  end

  def self.down
    drop_table :videos
  end
end
