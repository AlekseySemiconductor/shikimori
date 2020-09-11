class BbCodes::Markdown::ListQuoteParser
  include Singleton

  MARKDOWN_LIST_OR_QUOTE_REGEXP = %r{
    (?:
      (?: ^ | (?<=#{BLOCK_TAG_EDGE_REGEXP.source}) )
      (?: [-+*>] | &gt; )
      \ (?:
        (?: \[(?<tag>#{MULTILINE_BBCODES.join('|')})[\s\S]+\[/\k<tag>\] |. )*+
        (?: \n \ + .*+ )*
      ) (?: \n|$ )
    )+
  }x

  def format text
    text.gsub MARKDOWN_LIST_OR_QUOTE_REGEXP do |match|
      BbCodes::Markdown::ListQuoteParserState.new(match).to_html
    end
  end
end
