require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include ApplicationHelper

describe ApplicationHelper do
	describe 'display_time' do
			it "should display time" do
			time = Time.local(2008, 7, 4, 12, 30, 0, 0)
			display_time(time).should == "Jul 04 2008 12:30:00 PDT"
		end
	end
	
	describe 'render_member_login_menu' do
		def render(options)
			options
		end
		
		it "should render member menu if logged in" do
			self.stub!(:logged_in?).and_return(true)
			self.stub!(:current_user).and_return(users(:quentin))
			render_member_login_menu.should == {:partial => '/shared/member_menu'}
		end
		
		it "should render login menu unless logged in" do
			self.stub!(:logged_in?).and_return(false)
			render_member_login_menu.should == {:partial => '/shared/login_menu'}
		end
	end
	
	it 'should return category list' do
		category_list.should == Category.find(:all, :order => 'name') 
	end
	
	describe 'profile_url' do
		it 'should generate profile url if logged in' do
			self.stub!(:logged_in?).and_return(true)
			self.stub!(:current_user).and_return(users(:quentin))
			profile_url.should == edit_user_path(users(:quentin))
		end
		
		it 'should return blank string if not logged in' do
			self.stub!(:logged_in?).and_return(false)
			profile_url.should == ''
		end
	end
	
	describe 'featured_debates' do
		# TODO write actual tests once it's determined what the content should be
		it 'should return featured debates'
	end
end