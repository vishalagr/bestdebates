class CreateUserVariables < ActiveRecord::Migration
  def self.up
    create_table :user_variables, :force => true do |t|
      t.column :title, :string,  :null => false
      t.column :a, :integer , :null => false, :default => 1
      t.column :b, :integer ,:null => false, :default => 1
      t.column :c, :integer ,:null => false, :default => 1
      t.column :d, :integer ,:null => false, :default => 1
      t.column :e, :integer ,:null => false, :default => 1
      t.column :f, :integer ,:null => false, :default => 1
      t.column :g, :integer ,:null => false, :default => 1
      t.column :h, :integer ,:null => false, :default => 1
      t.column :i, :integer ,:null => false, :default => 1
      t.column :j, :integer ,:null => false, :default => 1
      t.column :k, :integer ,:null => false, :default => 1
      t.column :l, :integer ,:null => false, :default => 1
      t.column :m, :integer ,:null => false, :default => 1
      t.column :n, :integer ,:null => false, :default => 1
      t.column :o, :integer ,:null => false, :default => 1
      t.column :p, :integer , :null => false, :default => 1
      t.column :q, :integer , :null => false,:default => 1
      t.column :r, :integer , :null => false,:default => 1
      t.column :is_default, :integer
      t.column :active, :boolean
      t.timestamps
    end
  end

  def self.down
    drop_table :user_variables
  end
end
