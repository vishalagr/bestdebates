class SimilarArgument < ActiveRecord::Base
  belongs_to :argument
  validates_presence_of :argument, :identification_hash
  validates_uniqueness_of :argument_id

  
  # Return the record corresponding to the argument `arg`
  # Create it if it doesn't already exist
  def self.find_or_create_record(arg)
    unless (sim_arg = self.find_by_argument_id(arg.id))
      sim_arg = self.create!(
        :argument            => arg,
        :identification_hash => Digest::SHA1.hexdigest(Time.now.to_s << rand(1000).to_s)
      )
    end
    sim_arg
  end

  # Saves the similar argument
  # and associated similarity relationship in SimilarArgument
  def self.save_similar_argument(arg, id_hash, user)
    raise ActiveRecord::RecordNotFound unless (sim_arg = self.find_by_identification_hash(id_hash))

    # Save the argument and similar_argument together
    ActiveRecord::Base.transaction do
      # Save argument
      child = Argument.create!(
        :debate        => arg.debate,
        :user          => user,
        :title         => sim_arg.argument.title,
        :body          => sim_arg.argument.body,
        :argument_type => sim_arg.argument.argument_type,
        :draft         => false
      )
      child.move_to_child_of(arg)

      # Save similar_argument
      self.create!(:argument => child, :identification_hash => id_hash)
    end
  end

  def self.find_similar(arg_id)
    return [] unless arg_id

    similar_arg  = self.find_by_argument_id(arg_id)
    similar_args = self.find(
      :all,
      :conditions => ["identification_hash = ? AND id != ?", similar_arg.identification_hash, similar_arg.id]
    )
    similar_args.collect &:argument
  rescue
    []
  end
end
