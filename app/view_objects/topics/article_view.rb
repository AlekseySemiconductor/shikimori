class Topics::ArticleView < Topics::UserContentView
  BODY_TRUCATE_SIZE = 125

  delegate :tags, to: :article

  def container_classes
    super 'b-article-topic'
  end

  def need_trucation?
    true
  end

  def action_tag
    OpenStruct.new(
      type: 'article',
      text: i18n_i('article', :one)
    )
  end

  def url options = {}
    if is_mini
      canonical_url
    else
      super
    end
  end

  def canonical_url
    h.article_url article
  end

  def html_body
    text = @topic.decomposed_body.text

    if preview? || minified?
      text = text
        .gsub(%r{\[/?center\]}mix, '')
        .gsub(%r{\[(img|poster|image).*?\].*\[/\1\]}, '')
        .gsub(/\[(poster|image)=.*?\]/, '')
        .gsub(%r{\[spoiler.*?\]\s*\[/spoiler\]}, '')
        .strip
    end

    super(text)
  end

  def read_more_link?
    preview? || minified?
  end

  def skip_body?
    preview? && html_footer.present?
  end

  def footer_vote?
    false
  end

  def linked_in_avatar?
    false
  end

private

  def article
    @topic.linked
  end
end
