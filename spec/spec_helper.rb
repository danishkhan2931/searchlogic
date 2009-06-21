require 'spec'
require 'rubygems'
require 'ruby-debug'
require 'activerecord'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Base.configurations = true

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :companies do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end
  
  create_table :users do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :company_id
    t.string :username
    t.integer :age
  end
  
  create_table :orders do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :user_id
    t.date :shipped_on
    t.float :taxes
    t.float :total
  end
  
  create_table :line_items do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :order_id
    t.float :price
  end
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'searchlogic'

Spec::Runner.configure do |config|
  config.before(:each) do
    class Company < ActiveRecord::Base
      has_many :users, :dependent => :destroy
    end
    
    class User < ActiveRecord::Base
      belongs_to :company
      has_many :orders, :dependent => :destroy
      alias_scope :username_has, lambda { |value| username_like(value) }
    end
    
    class Order < ActiveRecord::Base
      belongs_to :user
      has_many :line_items, :dependent => :destroy
    end
    
    class LineItem < ActiveRecord::Base
      belongs_to :order
    end
    
    Company.destroy_all
    User.destroy_all
    Order.destroy_all
    LineItem.destroy_all
  end
  
  config.after(:each) do
    Object.send(:remove_const, :Company)
    Object.send(:remove_const, :User)
    Object.send(:remove_const, :Order)
    Object.send(:remove_const, :LineItem)
  end
end
