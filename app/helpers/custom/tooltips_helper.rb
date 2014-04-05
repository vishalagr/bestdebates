module Custom::TooltipsHelper
  def question_mark_tooltip(id, content)
    question_mark_image(:id => id , :class => "question_mark" , :alt => content)
  end
  
  
  def write_access_question_mark_tooltip
    question_mark_tooltip(rand, 'Allow invited user to post arguments')
  end
end
