#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

# CATEGORY_DATA = ['Arts', 'Beauty & Fashion', 'Business', 'Careers', 'Cars & Transport',
#   'Computers & Internet', 'Education', 'Electronics & Games', 'Environment', 'Family',
#   'Food & Drink', 'Health', 'History', 'Home & Gardening', 'Love & Relationship',
#   'Miscellaneous', 'Money', 'Music & Entertainment', 'Pets', 'Politics', 'Science',
#   'Shopping', 'Society', 'Sports', 'The Unknown', 'Travel']

CATEGORY_DATA = [
									['Politics', 'Discussions about government'],
									['Science', 'Scientific matters'],
									['Sports', 'Our favorite teams']
								]

CATEGORY_DATA.each do |name, description|
  Category.create(:name => name, :description => description)
end

class User
	attr_accessible :login, :email, :name, :password, :password_confirmation,
									:activated_at, :state
end

@user = User.new(
	:login => 'admin', :email => 'moderator@bestdebates.com',
	:name => 'Debate Moderator',
	:password => 'kn0w.lYdge!', :password_confirmation => 'kn0w.lYdge!'
)
@user.register!
@user.activate!
@user.save!

