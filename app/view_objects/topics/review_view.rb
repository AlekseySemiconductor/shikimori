class Topics::ReviewView < Topics::UserContentView
  def container_classes
    super 'b-review-topic'
  end

  def need_trucation?
    true
  end

  def minified?
    is_preview || is_mini
  end

  def action_tag
    OpenStruct.new(
      type: 'review',
      text: i18n_i('review', :one)
    )
  end

  def topic_title
    if preview?
      review.target.name
    else
      i18n_t(
        "title.#{review.target_type.downcase}",
        target_name: h.h(h.localized_name(review.target))
      ).html_safe
    end
  end

  def topic_title_html
    if preview?
      h.localization_span review.target
    else
      topic_title
    end
  end

  def html_body
    text = review.text

    if preview? || minified?
      text = text
        .gsub(%r{\[/?center\]}mix, '')
        .gsub(%r{\[(poster).*?\].*\[/\1\]}, '')
        .gsub(/\[poster=.*?\]/, '')
        .strip
        # .gsub(%r{\[spoiler.*?\]\s*\[/spoiler\]}, '')
        # .gsub(%r{\[(img|poster|image).*?\].*\[/\1\]}, '')
        # .gsub(/\[(poster|image)=.*?\]/, '')
    end

    stars_html + super(text)
  end

  def vote_results?
    review.votes_count.positive?
  end

private

  def body
    review.text
  end

  def stars_html
    h.render(
      partial: 'reviews/stars',
      locals: {
        review: review,
        with_music: review.entry.is_a?(Anime)
      },
      formats: :html
    )
  end

  def review
    @topic.linked
  end
end
