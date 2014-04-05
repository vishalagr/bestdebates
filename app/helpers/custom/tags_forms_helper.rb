module Custom::TagsFormsHelper
  # display:block needed for ul to avoid css selector conflict with atree
  def errors_box(errors)
    return nil if errors.blank?

    content_tag :div, :class => 'errorExplanation', :id => 'errorExplanation' do
      content_tag(:h2, "#{errors.size} errors prohibited this record from being saved", :style => "font-size:18px") <<
      content_tag(:p, 'There were problems with the following fields:') <<
      content_tag(:ul, :style => 'display:block') do
        errors.collect do |field, error|
          if field.is_a?(Hash)
            error = field.values.first
            field = field.keys.first
          end
          content_tag(:li, "#{field.titleize} #{error}", :class => 'liOpen', :style => 'margin-bottom: 2px; margin-top: 2px;')
        end.join("\n")
      end
    end
  end

  # Example:
  #  <% render_join(@items, '<br />') do |item| %>
  #     <p>Item title: <%= item.title %></p>
  #  <% end %>
  def render_join(tags, join_string='', &block)
    concat(tags.collect{|tag| capture(tag, &block) }.join(join_string), block.binding)
  end

  def tags(tags, join_string='', &block)
    return if tags.empty?

    render_join(tags, join_string, &block)
  end

  def tags_div(taggable_object)
    content_tag :div, :class => "tags_list" do
      content_tag :div, :id => taggable_object_dom_id(taggable_object) do
        "Tags: #{tags_links(taggable_object.tags, ',&nbsp;&nbsp;')}"
      end
    end
  end

  def tags_div_and_or_add_tag_form(taggable_object)
    m = if    taggable_object.is_a?(Argument)
          :can_edit_argument?
        elsif taggable_object.is_a?(Debate)
          :can_edit_debate?
        else
          raise "Unknown taggable object: #{taggable_object.class}"
        end

    if self.send(m, taggable_object)
      render :partial => 'shared/add_tags', :locals => {:taggable_object => taggable_object}
    else
      tags_div(taggable_object)
    end
  end
end
