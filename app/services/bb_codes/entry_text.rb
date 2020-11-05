class BbCodes::EntryText
  method_object :text, %i[entry locale]

  def call
    text = @entry ?
      remove_wiki_codes(character_names(prepare(@text), @entry)) :
      @text

    html = BbCodes::Text.call text
    html = finalize_names html if @locale

    <<-HTML.strip.html_safe
      <div class="b-text_with_paragraphs">#{html}</div>
    HTML
  end

private

  # the same logic as in BbCodes::Text
  def prepare text
    (text || '').fix_encoding.strip.gsub(/\r\n|\r/, "\n")
  end

  def character_names text, entry
    if entry.respond_to?(:characters) && entry.respond_to?(:people)
      BbCodes::CharactersNames.call text, entry
    else
      text
    end
  end

  # must be called after character_names
  # becase [[...]] are used in BbCodes::CharactersNames
  def remove_wiki_codes text
    return text unless @entry.is_a? Character

    text
      .gsub(/\[\[[^\]|]+?\|(.*?)\]\]/, '\1')
      .gsub(/\[\[(.*?)\]\]/, '\1')
  end

  def finalize_names
    case @locale.to_sym
      when :ru
        html
          .gsub(%r{<span class="name-ru">(.*?)</span>}, '\1')
          .gsub(%r{<span class="name-en">.*?</span>}, '')

      when :en
        html
          .gsub(%r{<span class="name-ru">.*?</span>}, '')
          .gsub(%r{<span class="name-en">(.*?)</span>}, '\1')
    end
  end
end
