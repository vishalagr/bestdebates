class CreateSupportPages < ActiveRecord::Migration
  def self.up
    create_table :support_pages do |t|
      t.string      :page_title, 	:null => false
      t.text        :video_code, 		:null => false
      t.text        :body, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :support_pages
  end
end
