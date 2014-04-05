class Argument < ActiveRecord::Base
  BG_COLORS      = {:teal => "corner-gray-green", :pink => "corner-gray-red",:blue => "corner-gray-blue", :white => 'corner-gray-white'}
  OPP_BG_COLORS_CODES  = {BG_COLORS[:teal] => 1, BG_COLORS[:pink] => 0, BG_COLORS[:white] => nil}
  BG_COLOR_CODES = {BG_COLORS[:teal] => 0, BG_COLORS[:pink] => 1,BG_COLORS[:blue] => 2, BG_COLORS[:white] => nil}
  
  THUMB_RELATIONS = {}
  
  # Update cached attributes of the argument and its descendands
  # change background color according to +argument_type+ attribute
  def update_cached_attrs!
    bg_color!# if @argument_type_changed
    relation_to_thumb!
    
    return unless children.size > 0
    
    children.each(&:update_cached_attrs!)
  end
  
  # Return background color of the argument from BG_COLORS
  def bg_color
    BG_COLOR_CODES.index(read_attribute(:bg_color))
  end

  def opposite_bg_color
    OPP_BG_COLORS_CODES.index(read_attribute(:bg_color))
  end
  
  # Set background color of the argument depending upon the
  # parent's background color and argument_type attribute
  #    A) if child is negative and parent is pink child is TEAL
  #    D) if child is positive and parent is TEAL child is TEAL
  #    B) if child is positive and parent is PINK child is PINK
  #    C) if child is negative and parent is TEAL child is PINK
  def bg_color!
    teal = BG_COLORS[:teal]
    pink = BG_COLORS[:pink]
    blue = BG_COLORS[:blue]
    
    teal_code = BG_COLOR_CODES[BG_COLORS[:teal]]
    pink_code = BG_COLOR_CODES[BG_COLORS[:pink]]
    blue_code = BG_COLOR_CODES[BG_COLORS[:blue]]

    bg = if parent && self.argument_type != 'com'
      if parent.bg_color == blue
        self.argument_type == 'pro' ? teal_code : (self.argument_type == 'con' ?  pink_code : blue_code)
      else
        if    (parent.bg_color == pink && self.argument_type != 'pro') || (parent.bg_color == teal && self.argument_type == 'pro')
          teal_code
        elsif (parent.bg_color == pink && self.argument_type == 'pro') || (parent.bg_color == teal && self.argument_type != 'pro')
          pink_code
        end
      end
    else
      # no parent
      self.argument_type == 'pro' ? teal_code : (self.argument_type == 'con' ?  pink_code : blue_code)
    end
    
    update_attribute :bg_color, bg
  end
    
  # Update relation_to_thumb attribute of the argument depending upon the
  # parent's relation_to_thumb and argument_type attribute
  #    C) if child is negative and parent is PRO, child is CON
  #    B) if child is positive and parent is CON, child is CON
  #    D) if child is positive and parent is PRO, child is PRO
  #    A) if child is negative and parent is CON, child is PRO
  def relation_to_thumb!
    r = if parent(true) && self.argument_type != 'com'
      if parent(true).relation_to_thumb == "com"
        self.argument_type
      else
        if    (parent(true).relation_to_thumb == "pro" && self.argument_type != 'pro') || (parent(true).relation_to_thumb != "pro" && self.argument_type == 'pro')
          'con'
        elsif (parent(true).relation_to_thumb == "pro" && self.argument_type == 'pro') || (parent(true).relation_to_thumb != "pro" && self.argument_type != 'pro')
          'pro'
        end
      end
    else
      # no parent
      self.argument_type
    end
    
    update_attribute :relation_to_thumb, r
  end
  
  private
  
#  def update_cached_attrs
#    update_children_argument_type! if @argument_type_changed
#    
#  end
end
