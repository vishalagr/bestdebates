require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DebatesController do
  describe "route generation" do

    it "should map { :controller => 'debates', :action => 'index' } to /debates" do
      route_for(:controller => "debates", :action => "index").should == "/debates"
    end
  
    it "should map { :controller => 'debates', :action => 'new' } to /debates/new" do
      route_for(:controller => "debates", :action => "new").should == "/debates/new"
    end
  
    it "should map { :controller => 'debates', :action => 'show', :id => 1 } to /debates/1" do
      route_for(:controller => "debates", :action => "show", :id => 1).should == "/debates/1"
    end
  
    it "should map { :controller => 'debates', :action => 'edit', :id => 1 } to /debates/1/edit" do
      route_for(:controller => "debates", :action => "edit", :id => 1).should == "/debates/1/edit"
    end
  
    it "should map { :controller => 'debates', :action => 'update', :id => 1} to /debates/1" do
      route_for(:controller => "debates", :action => "update", :id => 1).should == "/debates/1"
    end
  
    it "should map { :controller => 'debates', :action => 'destroy', :id => 1} to /debates/1" do
      route_for(:controller => "debates", :action => "destroy", :id => 1).should == "/debates/1"
    end

  end

  describe "route recognition" do

    it "should generate params { :controller => 'debates', action => 'index' } from GET /debates" do
      params_from(:get, "/debates").should == {:controller => "debates", :action => "index"}
    end
  
    it "should generate params { :controller => 'debates', action => 'new' } from GET /debates/new" do
      params_from(:get, "/debates/new").should == {:controller => "debates", :action => "new"}
    end
  
    it "should generate params { :controller => 'debates', action => 'create' } from POST /debates" do
      params_from(:post, "/debates").should == {:controller => "debates", :action => "create"}
    end
  
    it "should generate params { :controller => 'debates', action => 'show', id => '1' } from GET /debates/1" do
      params_from(:get, "/debates/1").should == {:controller => "debates", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'debates', action => 'edit', id => '1' } from GET /debates/1;edit" do
      params_from(:get, "/debates/1/edit").should == {:controller => "debates", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'debates', action => 'update', id => '1' } from PUT /debates/1" do
      params_from(:put, "/debates/1").should == {:controller => "debates", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'debates', action => 'destroy', id => '1' } from DELETE /debates/1" do
      params_from(:delete, "/debates/1").should == {:controller => "debates", :action => "destroy", :id => "1"}
    end
  end
end
