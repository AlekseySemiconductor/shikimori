class Misc::SanitizeEvilCss < ServiceObjectBase
  pattr_initialize :css

  COMMENTS_REGEXP = %r{
    /\* .*? \*/ \s* [\n\r]*
  }mix
  IMPORTS_REGEXP = /
    (?: @*import \s+ url \( ['"]? .*? ['"]? \); | @+import )\ ?[\n\r]*
  /mix

  EVIL_CSS = [
    # suspicious javascript-type words
    /(eval|cookie|\bwindow\b|\bparent\b|\bthis\b)/i,
    /behaviou?r|expression|moz-binding|@charset/i,
    /(java|vb)?script\b|</i,
    # back slash, html tags,
    # /[\<>]/,
    # high bytes -- suspect
    # /[\x7f-\xff]/,
    # low bytes -- suspect
    /[\x00-\x08\x0B\x0C\x0E-\x1F]+/,
    /&\#/, # bad charset
    COMMENTS_REGEXP,
    IMPORTS_REGEXP
  ]

  SPECIAL_REGEXP = /((?>content: ?['"].*?['"]))|\\\w/
  FIX_CONTENT_REGEXP = /(content: ?['"]\\)\\_(.*?['"])/
  DATA_IMAGE_REGEXP = %r{
    (?: \b|^ )
    (?:
      ((?>data:image/(?:svg\+xml|png|jpeg|jpg|gif);base64,))|data:(?:\b|$)
    )
  }ix

  def call
    fixed_css = fix_content(@css)

    loop do
      fixed_css, is_done = sanitize fixed_css
      break if is_done
    end

    fixed_css.gsub(/;;+/, ';')
  end

private

  def sanitize css
    prior_css = css
    new_css = EVIL_CSS
      .inject(css) { |styles, regex| styles.gsub(regex, '') }
      .gsub(SPECIAL_REGEXP, '\1')
      .gsub(DATA_IMAGE_REGEXP, '\1')
      .strip

    [new_css, new_css == prior_css]
  end

  def fix_content css
    css.gsub(FIX_CONTENT_REGEXP, '\1\2')
  end
end
