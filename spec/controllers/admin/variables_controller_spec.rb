require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::VariablesController do

  describe 'redirect to debates_url if user not admin_user' do
    before(:each) do
      login_as(:quentin)
    end

    after(:each) do
      response.should redirect_to(debates_url)
    end

    it 'GET  /admin/variables'        do get  :index;               end
    it 'GET  /admin/variables/1'      do get  :show, :id => 1;      end
    it 'POST /admin/variables'        do post :create;              end
    it 'GET  /admin/variables/new'    do get  :new;                 end
    it 'GET  /admin/variables/1/edit' do get  :edit, :id => 1;      end
    it 'PUT  /admin/variables/1'      do put  :update, :id => 1;    end
    it 'DELETE /admin/variables/1'    do delete :destroy, :id => 1; end
  end

  it 'handles GET /admin/variables/1/activate' do
    Variable.should_receive(:update_all).with('active = 0', ['id != ?', 123]).and_return(true)
    Variable.should_receive(:update_all).with('active = 1', ['id  = ?', 123]).and_return(true)

    login_as(:admin)
    get :activate, :id => 123
    response.should redirect_to(admin_variables_url)
  end
end
