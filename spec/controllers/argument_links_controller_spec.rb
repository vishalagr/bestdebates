require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArgumentLinksController do

  describe "handle POST '/arguments/1/links'" do

    before(:each) do
      @argument = Factory.create(:argument, :user => users(:quentin))
    end

    describe 'handle POST /arguments/1/links' do
      before(:each) do
        login_as(:quentin)
      end

      it "should not let an unauthorized user create an argument_link" do
        controller.stub!(:can_edit_argument?).and_return(false)
        lambda {
          xhr :post, :create, {:argument_id => @argument.id, :link => {:url => "google.com"}}
        }.should_not change(ArgumentLink, :count)
        assigns[:argument_link].should be_nil
        flash[:error].should == 'You don\'t have permissions to edit this argument'
      end

      it "should let the owner create links" do
        lambda {
          xhr :post, :create, {:argument_id => @argument.id, :link => {:url => "google.com"}}
        }.should change(ArgumentLink, :count).by(1)
        assigns('argument_link').should be_valid
        assigns('argument_link').url.should =~ /google.com/
      end
    end

    it "should let the owner delete links" do
      argument_link = Factory.create(:argument_link, :argument => @argument)

      login_as(:quentin)
      lambda do
        xhr :delete, :destroy, {:argument_id => @argument.id, :id => argument_link.id}
      end.should change(ArgumentLink, :count).by(-1)
    end

    it "should not let other users add links" do
      login_as(:aaron)

      lambda do
        xhr :post, :create, {:argument_id => @argument.id, :link => {:url => "google.com"}}
      end.should_not change(ArgumentLink, :count)

      assigns['argument_link'].should be_nil
    end
  end

end

