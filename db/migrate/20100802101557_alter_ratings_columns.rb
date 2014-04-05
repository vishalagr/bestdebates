class AlterRatingsColumns < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE ratings CHANGE relevance relevance FLOAT( 11 ) NOT NULL")
	  execute("ALTER TABLE ratings CHANGE accuracy accuracy FLOAT( 11 ) NOT NULL")
	  execute("ALTER TABLE ratings CHANGE clarity  clarity FLOAT( 11 ) NOT NULL")
  end

  def self.down
    execute("ALTER TABLE ratings CHANGE relevance relevance INT( 11 ) NOT NULL")
	  execute("ALTER TABLE ratings CHANGE accuracy accuracy INT( 11 ) NOT NULL")
	  execute("ALTER TABLE ratings CHANGE clarity  clarity INT( 11 ) NOT NULL")
  end
end
