require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvitationsController do

  include CustomFactory
  include MockFactory

  describe 'without logged in' do
    after(:each) do
      response.should redirect_to(new_session_path)
    end

    it 'index' do
      get :index, :debate_id => 1
    end

    it 'create' do
      post :create, :debate_id => 1
    end

    it 'update' do
      post :update_multiple, :debate_id => 1, :id => 1
    end
  end



  describe 'for logged in users' do

    # index
    describe 'handles GET /debates/1/invitations' do

      before(:each) do
        @current_user = users(:quentin)

        @debate = mock_debate(:user => @current_user)
        Debate.stub!(:first).and_return(@debate)
        @invitation = mock_invitation(:resource => @debate)
        @user = mock_user
        @invitation2 = mock_invitation(:resource => @debate, :user => @user)

        @debate.stub!(:guests).and_return([@invitation])
        @debate.stub!(:invited_users).and_return([@user])
        @debate.stub!(:can_be_invited_by?).and_return(true)

        login_as(:quentin)
      end

      def get_index(attribs = {})
        get :index, {:debate_id => @debate.id}.merge(attribs)
      end

      it 'should redirect to debate_path if user can\'t invite' do
        @debate.stub!(:can_be_invited_by?).and_return(false)
        get_index
        response.should redirect_to(debate_url(@debate))
        flash[:error].should == 'You can\'t invite!'
      end

      it 'if debate.can_be_modified_by?(current_user)' do
        @debate.stub!(:can_be_modified_by?).and_return(true)
        @debate.should_receive(:guests).with().once
        @debate.should_receive(:invited_users).with().once
        get_index
        response.should be_success
      end

      it 'if debate.cannot_be_modified_by?(current_user)' do
        @debate.stub!(:can_be_modified_by?).and_return(false)
        @debate.should_receive(:guests).with(["invitor_id = '#{@current_user.id}'"]).once
        @debate.invited_users.should_receive(:all).with(:conditions => ['invitor_id = ?', @current_user]).once.and_return([@current_user])
        get_index
        response.should be_success
      end
    end



    # create
    describe 'handles POST /debates/1/invitations' do

      before(:each) do
        @current_user = users(:quentin)

        @debate = mock_debate(:user => @current_user)
        Debate.stub!(:first).and_return(@debate)
        @invitation = mock_invitation(:resource => @debate)
        @user = mock_user
        @invitation2 = mock_invitation(:resource => @debate, :user => @user)
        @inv_eng = mock_model(InvitationEngine)

        @debate.stub!(:guests).and_return([@invitation])
        @debate.stub!(:invitations).and_return(@invitation)
        @debate.stub!(:invited_users).and_return([@user])
        @debate.stub!(:can_be_invited_by?).and_return(true)
        @debate.stub!(:can_be_modified_by?).and_return(true)

        @invitation.stub!(:is_writable?).and_return(true)
        @invitation.stub!(:find_by_user_id).and_return(@invitation)
        @user.stub!(:invitation_id).and_return(@invitation.id)
        @user.stub!(:is_writable?).and_return(true)

        InvitationEngine.stub!(:new).and_return(@inv_eng)
        @inv_eng.stub!(:proceed).and_return(true)
        @inv_eng.stub!(:records_count).and_return(2)

        login_as(:quentin)
      end

      def do_create(attribs = {})
        post :create, {:debate_id => @debate.id}.merge(attribs)
      end

      it 'proceeds inv_eng with errors' do
        params = {"debate_id"=>@debate.id.to_s, "action"=>"create", "controller"=>"invitations"}
        InvitationEngine.should_receive(:new).with(@current_user, @debate, params).and_return(@inv_eng)
        @inv_eng.should_receive(:proceed)

        @inv_eng.stub!(:errors).and_return(['err-1', 'err-2'])

        @inv_eng.stub!(:new_users?).and_return(false)
        @inv_eng.stub!(:exists_users?).and_return(false)

        do_create
        flash[:error].should == "err-1<br />err-2"
        response.should be_success
      end

      it 'proceeds inv_eng without errors' do
        @inv_eng.stub!(:errors).and_return(nil)
        @inv_eng.stub!(:new_users?).and_return(false)
        @inv_eng.stub!(:exists_users?).and_return(true)

        do_create
        response.should be_success
      end

      it 'proceeds inv_eng without errors for new_users' do
        @inv_eng.stub!(:errors).and_return(nil)
        @inv_eng.stub!(:new_users?).and_return(true)

        do_create
        response.should be_success
      end
    end

    # update_multiple
    describe 'handles POST /debates/1/invitations/1/update_multiple' do
      before(:each) do
        @current_user = users(:quentin)

        @debate = mock_debate(:user => @current_user)
        Debate.stub!(:first).and_return(@debate)
        @invitation = mock_invitation(:resource => @debate)
        @user = mock_user
        @invitation2 = mock_invitation(:resource => @debate, :user => @user)
        @inv_eng = mock_model(InvitationEngine)

        @debate.stub!(:guests).and_return([@invitation])
        @debate.stub!(:invitations).and_return(@invitation)
        @debate.stub!(:invited_users).and_return([@user])
        @debate.stub!(:can_be_invited_by?).and_return(true)
        @debate.stub!(:can_be_modified_by?).and_return(true)

        @invitation.stub!(:is_writable?).and_return(true)
        @invitation.stub!(:find_by_user_id).and_return(@invitation)
        @user.stub!(:invitation_id).and_return(@invitation.id)
        @user.stub!(:is_writable?).and_return(true)

        InvitationEngine.stub!(:new).and_return(@inv_eng)
        @inv_eng.stub!(:update_multiple).and_return(true)
        @inv_eng.stub!(:records_count).and_return(2)

        login_as(:quentin)
      end

      def do_update_multiple(attribs = {})
        post :update_multiple, {:debate_id => @debate.id, :id => @invitation.id}.merge(attribs)
      end

      it 'updates multiple invitation engines' do
        params = {"debate_id"=>@debate.id.to_s, "action"=>"update_multiple", "id"=>@invitation.id.to_s, "controller"=>"invitations"}
        InvitationEngine.should_receive(:new).with(@current_user, @debate, params).and_return(@inv_eng)
        @inv_eng.should_receive(:update_multiple)
        
        do_update_multiple
        flash[:notice].should =~ / was updated\.$/
        response.should be_success
      end
    end
  end

  describe 'POST /debates/1/invitations/1/resend_email' do
    before(:each) do
      @user   = users(:quentin)
      @debate = mock_debate
      Debate.stub!(:first).and_return(@debate)

      @invitation = mock_invitation(:resource => @debate)
      Invitation.stub!(:find).and_return(@invitation)
      @invitation.stub!(:invitor).and_return(@user)
      @invitation.stub!(:resource).and_return(@debate)

      controller.stub!(:current_user).and_return(@user)
    end

    def do_resend_email(attribs = {})
      post :resend_email, {:id => 1, :debate_id => 1}.merge(attribs)
    end

    it 'redirects to debate_path if cannot invite' do
      @debate.stub!(:can_be_invited_by?).with(@user).and_return(false)

      login_as(:quentin)
      do_resend_email
      flash[:error].should == 'You can\'t invite!'
      response.should redirect_to(debate_path(@debate))
    end

    it 'resends email successfully' do
      @debate.stub!(:can_be_invited_by?).with(@user).and_return(true)
      Mailers::Debate.should_receive(:deliver_invitation).with(@user, @debate, @invitation).once.and_return(true)

      login_as(:quentin)
      do_resend_email

      flash[:notice].should == 'Invitation email successfully resent'
      response.should have_rjs
    end

    it 'fails to resend email' do
      @debate.stub!(:can_be_invited_by?).with(@user).and_return(true)
      Mailers::Debate.should_receive(:deliver_invitation).with(@user, @debate, @invitation).once.and_raise(NoMethodError)

      login_as(:quentin)
      do_resend_email

      flash[:error].should == 'Couldn\'t resend the invitation email'
      response.should have_rjs
    end
  end

  it 'handles POST /debates/1/invitations/preview_email successfully' do
    @user   = users(:quentin)
    @debate = mock_debate
    @mail   = mock(Mailers::Debate, :body => 'X No message provided Y')
    Debate.stub!(:first).and_return(@debate)
    @invitation = mock_invitation
    Invitation.should_receive(:new).and_return(@invitation)
    @debate.stub!(:can_be_invited_by?).with(@user).and_return(true)
    Mailers::Debate.should_receive(:create_invitation).with(@user, @debate, @invitation).once.and_return(@mail)
    controller.stub!(:current_user).and_return(@user)

    login_as(:quentin)
    post :preview_email, {:debate_id => 1}

    assigns[:mail_body].should == 'X YOUR PERSONALIZED NOTE GOES HERE Y'
    response.should be_success
  end

end
