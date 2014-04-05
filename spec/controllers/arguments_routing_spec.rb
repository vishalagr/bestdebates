require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArgumentsController do
  describe "route generation in debate namespace" do
	
    it "should map { :controller => 'arguments', :action => 'new' } to /debates/1/arguments/new" do
      route_for(:controller => "arguments", :action => "new", :debate_id => 1).should == "/debates/1/arguments/new"
    end

    it "should map { :controller => 'arguments', :action => 'show' } to /debates/1/arguments/1" do
      route_for(:controller => "arguments", :action => "show", :debate_id => 1, :id => 2).should == "/debates/1/arguments/2"
    end

	  it "should map { :controller => 'arguments', :action => 'rate', :id => 2, :debate_id => 1 } to /debates/1/arguments/1/rate" do
      route_for(:controller => "arguments", :action => "rate", :debate_id => 1, :id => 2).should == "/debates/1/arguments/2/rate"
    end
  end
  
  describe "route generation in admin namespace" do

    it "should map { :controller => 'arguments', :action => 'edit', :id => 1 } to /arguments/1/edit" do
      route_for(:controller => "arguments", :action => "edit", :id => 1).should == "/arguments/1/edit"
    end
  
    it "should map { :controller => 'arguments', :action => 'update', :id => 1} to /arguments/1" do
      route_for(:controller => "arguments", :action => "update", :id => 1).should == "/arguments/1"
    end
  
    it "should map { :controller => 'arguments', :action => 'destroy', :id => 1} to /arguments/1" do
      route_for(:controller => "arguments", :action => "destroy", :id => 1).should == "/arguments/1"
    end

  end

  describe "route recognition in debate namespace" do
  
    it "should generate params { :controller => 'arguments', :debate_id => 1, :action => 'new' } from GET /debates/1/arguments/new" do
      params_from(:get, "/arguments/new").should == {:controller => "arguments", :action => "new"}
    end
  
    it "should generate params { :controller => 'arguments', action => 'create' } from POST /arguments" do
      params_from(:post, "/arguments").should == {:controller => "arguments", :action => "create"}
    end
    
    it "should generate params { :controller => 'arguments', action => 'rate', debate_id => '1', id => '2' } from POST /arguments/1;rate" do
      params_from(:post, "/debates/1/arguments/2/rate").should == {:controller => "arguments", :action => "rate", :id => "2", :debate_id => "1"}
    end

  end

  describe "route recognition in admin namespace" do
  
    it "should generate params { :controller => 'arguments', action => 'edit', id => '1' } from GET /arguments/1;edit" do
      params_from(:get, "/arguments/1/edit").should == {:controller => "arguments", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'arguments', action => 'update', id => '1' } from PUT /arguments/1" do
      params_from(:put, "/arguments/1").should == {:controller => "arguments", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'arguments', action => 'destroy', id => '1' } from DELETE /arguments/1" do
      params_from(:delete, "/arguments/1").should == {:controller => "arguments", :action => "destroy", :id => "1"}
    end
  end
end
