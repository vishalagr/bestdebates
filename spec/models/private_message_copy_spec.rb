require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PrivateMessageCopy do
  before(:each) do
    @author = Factory.create(:user)
    @user1 = Factory.create(:user)
    @user2 = Factory.create(:user)
    
    @msg = PrivateMessage.new(
      :subject => "first msg",
      :body => "hello world"
    )
    @msg.author = @author
    @msg.to_users = "#{@user1.id}, #{@user2.id}"
    @msg.save!
  end
  
  it "should set status of a new private message to unread via PrivateMessageCopy" do
    @user1.inbox.private_messages.each {
      |msg|     
      msg.status.should == "unread"
    }
  end
  
  it "should display the details of a private message" do
    @user1.inbox.private_messages.each {
      |msg|     
      msg.author.email.should == @author.email
      msg.subject.should == "first msg"
      msg.body.should == "hello world"
      msg.recipients.collect(&:email).sort.should == [@user1.email, @user2.email].sort
    }
  end
  
  it "should mark private message as read" do
    @user1.inbox.private_messages.each {
      |msg|     
      msg.status.should == "unread"
      msg.mark_as_read
      msg.status.should == "read"
    }
  end
  
end
