module Custom::ButtonsHelper
  def button_submit_save(options={})
    image_submit_tag 'save.png', {:class => 'left create-button', :style => 'border: none;'}.merge(options)
  end

  def button_cancel(options={})
    image_tag 'cancel.png', {:class => 'right cancel-button', :style => 'border: none;'}.merge(options)
  end
end
