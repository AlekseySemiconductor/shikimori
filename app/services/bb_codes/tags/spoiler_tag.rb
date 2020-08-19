class BbCodes::Tags::SpoilerTag
  include Singleton

  LABEL_REGEXP = /(?:=(?<label>[^\[\]\n\r]+?))?/
  REGEXP = %r{
    (?<prefix>
      ^ | \n | </p> | <div[^>]*+> | </div>
    )?
    \[(?<tag>spoiler(?:_block|_v1)?) #{LABEL_REGEXP.source} \]
      \n?
      (?<content>
        (?:
          (?! \[/?spoiler(?:_block|_v1)? #{LABEL_REGEXP.source} \] ) (?>[\s\S])
        )+
      )
      \n?
    \[/\k<tag>\]
    (?<suffix>\n)?
  }xi

  TAG_REGEXP = %r{</?\w+}

  TEXT_CONTENT_REGEXP = /\A[^\n\[\]]++\Z/
  INLINE_LABELS = ['spoiler', 'спойлер', nil]

  def format text
    spoiler_to_html text, 0
  end

private

  def spoiler_to_html text, nesting
    return text if nesting > 5

    text = spoiler_to_html text, nesting + 1

    text.gsub(REGEXP) do |_match|
      tag = $LAST_MATCH_INFO[:tag]
      label = $LAST_MATCH_INFO[:label]&.strip || I18n.t('markers.spoiler')
      content = $LAST_MATCH_INFO[:content]
      prefix = $LAST_MATCH_INFO[:prefix]
      suffix = $LAST_MATCH_INFO[:suffix] || ''

      to_html tag, label, content, prefix, suffix
    end
  end

  def to_html tag, label, content, prefix, suffix # rubocop:disable all
    method_name =
      if tag == 'spoiler_block'
        :block_spoiler_html
      elsif tag == 'spoiler_v1'
        :old_spoiler_html
      elsif prefix.nil? && inline?(label, content)
        :inline_spoiler_html
      elsif prefix.nil? || label.match?(TAG_REGEXP)
        :old_spoiler_html
      else
        :block_spoiler_html
      end

    suffix = '' if method_name == :block_spoiler_html

    (prefix || '') + send(method_name, label, content) + (suffix || '')
  end

  def inline_spoiler_html _label, content
    "<span class='b-spoiler_inline to-process' data-dynamic='spoiler_inline'>" \
      "<span>#{content}</span>" \
    '</span>'
  end

  def old_spoiler_html label, content
    "<div class='b-spoiler unprocessed'>" \
      "<label>#{label}</label>" \
      "<div class='content'>" \
        "<div class='before'></div>" \
        "<div class='inner'>#{content}</div>" \
        "<div class='after'></div>" \
      '</div>' \
    '</div>'
  end

  def block_spoiler_html label, content
    "<div class='b-spoiler_block to-process' data-dynamic='spoiler_block'>" \
      "<button>#{label}</button>" \
      "<div>#{content.rstrip}</div>" \
    '</div>'
  end

  def inline? label, content
    label.in?(INLINE_LABELS) && content.match?(TEXT_CONTENT_REGEXP)
  end
end
