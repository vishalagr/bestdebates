# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'factory_girl'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  require "#{RAILS_ROOT}/spec/factories.rb"

  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  config.global_fixtures = :categories, :users, :debates, :arguments
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

include AuthenticatedTestHelper

module CustomFactory
	
	def valid_category_attributes
		{ 
			:name => 'Name', 
			:description => 'Category Description'
		}
	end

	def valid_user_attributes
		{
			:login => 'quire', 
			:name => 'Quire', 
			:email => 'quire@example.com', 
			:password => 'quire69', 
			:password_confirmation => 'quire69'
		}
	end	
	
	def valid_debate_attributes
		{ 
			:category => create_category,
			:user => create_user,
			:title => 'Title',
			:body => 'This is the body of the debate',
			:link => 'http://www.google.com' 
		}
	end
	
	def valid_argument_attributes
		{
			:title => 'This argument is false',
			:argument_type => 'pro',
			:body => "Don't believe a word of this argument; you're a fool if you do.",
			:evidence_type => 'undermine',
			:user => create_user,
			:debate => create_debate,
			:score => 5,
      :user_id => 1,
      :debate_id => 1
			#:clarification => 'clarification',
			#:evidence => 'evidence',
			#:reasoning => 'reasoning'
		}
	end
	
  def valid_argument_link_attributes
    {
      :argument => create_argument,
      :url => 'google.com',
      :title => 'some title'
    }
  end

	def valid_rating_attributes
    {
      :argument => create_argument,
      :user => create_user, 
      :accuracy => 6,
      :clarity => 1,
      :relevance => 4
    }
	end
	
  def valid_invitation_attributes
    {
      :debate => create_debate,
      :user => create_user,
      :invitor => create_user,
      :is_writable => true,
      :email => 'someone@bestdebates.com'
    }
  end

	def create_argument(attributes = {})
		parent = attributes.delete(:parent)
		Argument.new(valid_argument_attributes.merge(attributes))
	end
	
	def create_category(attributes = {})
		Category.new(valid_category_attributes.merge(attributes))
	end
	
	def create_user(attributes = {})
		User.new(valid_user_attributes.merge(attributes))
	end
	
	def create_debate(attributes = {})
		Debate.new(valid_debate_attributes.merge(attributes))
	end
	
	def create_rating(attributes = {})
		Rating.new(valid_rating_attributes.merge(attributes))
	end
	
end

module MockFactory

	def valid_category_attributes
		{ 
			:name => 'Name', 
			:description => 'Category Description'
		}
	end

	def valid_user_attributes
		{
			:login => 'quire', 
			:name => 'Quire', 
			:email => 'quire@example.com', 
			:password => 'quire69', 
			:password_confirmation => 'quire69'
		}
	end	
	
	def valid_debate_attributes
		{ 
			:category => mock_category,
			:category_id => 1,
			:user => mock_user,
			:title => 'Title',
			:body => 'This is the body of the debate',
			:tag_list => 'foo, bar, baz'
		}
	end
	
	def valid_rating_attributes
    {
      :argument => mock_argument,
      :user_id => 1,
      :accuracy => 8,
      :clarity => 5,
      :relevance => 3
    }
	end
	
	def timestamps
		{
			:created_at => 1.day.ago, :updated_at => 1.hour.ago
		}
	end
	
	def mock_argument(attributes = {})
		mock_model(Argument, valid_argument_attributes.merge(timestamps).merge(attributes))
	end
	
	def mock_category(attributes = {})
		mock_model(Category, valid_category_attributes.merge(timestamps).merge(attributes))
	end
	
	def mock_user(attributes = {})
		mock_model(User, valid_user_attributes.merge(timestamps).merge(attributes))
	end
	
	def mock_debate(attributes = {})
		mock_model(Debate, valid_debate_attributes.merge(timestamps).merge(attributes))
	end
	
	def mock_rating(attributes = {})
		mock_model(Rating, valid_rating_attributes.merge(timestamps).merge(attributes))
	end
		
  def mock_invitation(attributes = {})
    mock_model(Invitation, valid_invitation_attributes.merge(timestamps).merge(attributes))
  end
end
