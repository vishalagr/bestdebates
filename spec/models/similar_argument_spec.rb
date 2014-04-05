require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SimilarArgument do
	
  before(:each) do
    @similar_argument = Factory.build(:similar_argument)
  end

  it 'requires an argument' do
    @similar_argument.argument = nil
    @similar_argument.should have(1).error_on(:argument)
  end

  it 'requires an identification_hash' do
    @similar_argument.identification_hash = nil
    @similar_argument.should have(1).error_on(:identification_hash)
  end

  it 'requires argument_id to be unique' do
    @similar_argument.save
    @similar_argument_2 = Factory.build(:similar_argument, :argument_id => @similar_argument.argument.id)
    @similar_argument_2.should have(1).error_on(:argument_id)
  end

  it 'should find_or_create_record' do
    # Find
    @similar_argument.save
    lambda do
      SimilarArgument.find_or_create_record(@similar_argument.argument).should == @similar_argument
    end.should_not change(SimilarArgument, :count)

    # Create
    @argument = Factory.create(:argument)
    lambda do
      @similar_argument_2 = SimilarArgument.find_or_create_record(@argument)
    end.should change(SimilarArgument, :count).by(1)
    @similar_argument_2.argument.should == @argument
  end

  it 'should save a similar argument' do
    @argument = @similar_argument.argument
    lambda do
      SimilarArgument.save_similar_argument(@argument, 'xyz', @argument.user)
    end.should raise_error(ActiveRecord::RecordNotFound)

    @similar_argument.save
    lambda do
      SimilarArgument.save_similar_argument(@argument, @similar_argument.identification_hash, @argument.user)
    end.should change(Argument, :count).by(1)
  end

  it 'should find_similar arguments' do
    SimilarArgument.find_similar(nil).should == []

    @similar_argument.save
    @similar_argument_2 = Factory.create(
      :similar_argument,
      :identification_hash => @similar_argument.identification_hash
    )
    @similar_argument_3 = Factory.create(
      :similar_argument,
      :identification_hash => @similar_argument.identification_hash
    )

    SimilarArgument.find_similar(@similar_argument.argument.id).should == [@similar_argument_2.argument, @similar_argument_3.argument]
  end
end
