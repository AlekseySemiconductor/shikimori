# комментарий с description описанием вместо обычного body
# использутеся для превью текстов описаний
class DescriptionComment < SimpleDelegator
  def initialize comment, target_type, target_id
    super comment
    @target = target_type.constantize.find(target_id)
  end

  def html_body
    BbCodes::Description.call body, @target
  end
end
