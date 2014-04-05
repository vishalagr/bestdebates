require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Variable do

  before(:each) do
    @variable = Factory.build(:variable)
  end

  it "should find the default" do
    @variable.title = 'Default' and @variable.save
    Variable.default.should == @variable
  end

  it "should find the current" do
    @variable.active = true and @variable.save
    Variable.current.should == Variable.first(:conditions => "active = true")
  end

  it "should get the details" do
    string = "#{@variable.title} #{@variable.active} "
    string << %w(x q z r y).collect { |name|
      "#{name}: #{@variable.send(name.to_sym)}"
    }.join(',')

    @variable.details.should == string
  end

end
