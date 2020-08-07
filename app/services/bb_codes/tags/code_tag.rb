class BbCodes::Tags::CodeTag
  BBCODE_REGEXP = %r{
    \[ code (?:=(?<language>[\w+#-]+))? \]
      (?<before> \ + | \ +[\r\n]+ | [\r\n]* )
      (?<code> .*? )
      (?<after> [\ \r\n]* )
    \[ /code \] |
    ^ ``` (?<language>[\w+#-]+)? \n
      (?<code_block> .*? ) \n
    ^ ``` (?:\n|$)
  }mix

  MARKDOWN_REGEXP = /(?<mark>`++)(?<code>(?:(?!\k<mark>).)+)\k<mark>/

  CODE_PLACEHOLDER = "<<-CODE-PLACEHODLER->>\n"
  CODE_PLACEHOLDER_2 = "<<-CODE-PLACEHODLER-2->>\n"

  CODE_PLACEHOLDER_REGEXP = /<<-CODE-PLACEHODLER->>(?:<br>|\n|)/
  CODE_PLACEHOLDER_2_REGEXP = /<<-CODE-PLACEHODLER-2->>(?:<br>|\n|)/

  class BrokenTagError < RuntimeError
  end

  def initialize text
    @text = text
    @cache = []
  end

  def preprocess
    proprocess_markdown(preprocess_bbcode(@text))
  end

  def postprocess text
    fixed_text = postprocess_markdown(postprocess_bbcode(text))

    raise BrokenTagError if @cache.any?

    fixed_text
  end

  def restore text
    text
      .gsub(CODE_PLACEHOLDER_2_REGEXP) { @cache.shift.original }
      .gsub(CODE_PLACEHOLDER_REGEXP) { @cache.shift.original }
  end

private

  def preprocess_bbcode text
    text.gsub BBCODE_REGEXP do |match|
      store(
        $LAST_MATCH_INFO[:code] || $LAST_MATCH_INFO[:code_block],
        $LAST_MATCH_INFO[:language],
        $LAST_MATCH_INFO[:code_block] ? 'z' : $LAST_MATCH_INFO[:before],
        $LAST_MATCH_INFO[:code_block] ? 'z' : $LAST_MATCH_INFO[:after],
        match
      )
      CODE_PLACEHOLDER
    end
  end

  def postprocess_bbcode text
    text.gsub CODE_PLACEHOLDER_REGEXP do
      code = @cache.shift

      raise BrokenTagError if code.nil?

      if code.language
        code_highlight code.text, code.language
      elsif code_block? code.text, code.content_around
        code_highlight code.text, nil
      else
        code_inline code.text
      end
    end
  end

  def proprocess_markdown text
    text.gsub MARKDOWN_REGEXP do |match|
      store(
        $LAST_MATCH_INFO[:code],
        nil,
        nil,
        nil,
        match
      )
      CODE_PLACEHOLDER_2
    end
  end

  def postprocess_markdown text
    text.gsub CODE_PLACEHOLDER_2_REGEXP do
      code = @cache.shift
      raise BrokenTagError if code.nil?

      code_inline code.text
    end
  end

  def code_highlight text, language
    "<pre class='b-code-v2 to-process' data-dynamic='code_highlight' "\
      "data-language='#{language}'><code>#{text}</code></pre>"
  end

  def code_inline text
    "<code class='b-code_inline'>#{text}</code>"
  end

  def code_block? text, content_around
    text.include?("\n") || text.include?("\r") || content_around
  end

  def store text, language, before, after, original
    @cache.push OpenStruct.new(
      text: text,
      language: language,
      content_around: (!before.empty? if before) || (!after.empty? if after),
      original: original
    )
  end
end
