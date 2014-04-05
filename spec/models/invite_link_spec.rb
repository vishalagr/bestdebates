require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InviteLink do
  before(:each) do
    @invite_link = Factory.build(:invite_link)
  end

  it 'should be valid' do
    @invite_link.should be_valid
  end

  it 'should require resource' do
    @invite_link.resource = nil
    @invite_link.should_not be_valid
    @invite_link.should have(1).error_on(:resource)
  end

  it 'should require resource_type' do
    @invite_link.resource_type = nil
    @invite_link.should_not be_valid
    @invite_link.should have(1).error_on(:resource_type)
  end

  it 'should require user' do
    @invite_link.user = nil
    @invite_link.should_not be_valid
    @invite_link.should have(1).error_on(:user)
  end

  it 'should require unique_id' do
    @invite_link.unique_id = nil
    @invite_link.should_not be_valid
    @invite_link.should have(1).error_on(:unique_id)
  end

  it 'should have unique unique_id' do
    @invite_link.unique_id = '12345678' and @invite_link.save

    inv_link = Factory.build(:invite_link, :unique_id => @invite_link.unique_id)
    inv_link.should have(1).error_on(:unique_id)
  end

  it 'should have unique pair of (title, user_id)' do
    @invite_link.save

    @inv_link = Factory.build(:invite_link, :unique_id => Time.now.to_i.to_s, :title => @invite_link.title, :user => @invite_link.user)
    @inv_link.save
    @inv_link.errors['title'].should == 'You have already created an invitation title with that name'
  end

  it 'should get invited_users' do
    @invite_link.save
    user_resource = Factory.create(:user_resource, :invite_link => @invite_link)

    @invite_link.invited_users.should == [user_resource.user]
  end

  it 'should connect! a user' do
    @invite_link.save

    lambda do
      user = Factory.create(:user)
      @invite_link.connect!(user)
    end.should change(@invite_link.resource.joined_users, :count).by(1)
  end

  it 'should get display_title' do
    @invite_link.title, @invite_link.unique_id = '', '8192310293'
    @invite_link.display_title.should == @invite_link.unique_id

    @invite_link.title, @invite_link.unique_id = 'TiTlE', '8192310293'
    @invite_link.display_title.should == @invite_link.title
  end
end
