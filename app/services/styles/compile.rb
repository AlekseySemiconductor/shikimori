class Styles::Compile
  method_object :css

  MEDIA_QUERY_CSS = '@media only screen and (min-width: 1024px)'

  IMPORTS_REGEXP = /
    @import \s+ url \( ['"]? (?<url>.*?) ['"]? \);
    [\n\r]*
  /mix
  SUFFIX_REGEXP = /
    (?<suffix>
      ["'`;)]+
      (?:\s*!important)?
    )$
  /mix

  USER_CONTENT = 'User Custom Styles'

  def call
    imports, css_wo_imports = extract_imports(@css)
    styles_map = download_imports(imports)

    compiled_css = (
      inline_imports(styles_map) + "\n\n" +
        media_query(compile(css_wo_imports), USER_CONTENT)
    ).strip

    {
      compiled_css: compiled_css,
      imports: imports
    }
  end

private

  def inline_imports styles_map
    styles_map
      .select { |_k, v| v.present? }
      .map { |url, css| compile css, url }
      .select(&:present?)
      .join("\n\n")
  end

  def download_imports imports
    imports.each_with_object({}) do |url, memo|
      memo[url] = Styles::Download.call(url)
    end
  end

  def compile css, url = nil
    compiled_css = strip_comments(sanitize(camo_images(css))).strip

    if compiled_css.present?
      url ?
        "/* #{url} */\n" + compiled_css :
        compiled_css
    end
  end

  def media_query css, url
    return '' if css.blank?

    prefix = "/* #{url} */\n"

    if css.gsub(%r{^/\* AUTO=.*}, '').include?('@media')
      prefix + css
    else
      "#{prefix}#{MEDIA_QUERY_CSS} {\n#{css}\n}"
    end
  end

  def camo_images css
    css.gsub(BbCodes::Tags::UrlTag::URL) do
      url = $LAST_MATCH_INFO[:url]

      if url =~ SUFFIX_REGEXP
        suffix = $LAST_MATCH_INFO[:suffix]
        url = url.gsub(SUFFIX_REGEXP, '')
      end

      "#{UrlGenerator.instance.camo_url url, force_shikimori_one: true}#{suffix}"
    end
  end

  def sanitize css
    Misc::SanitizeEvilCss
      .call(css)
      .gsub(/;;+/, ';')
      .strip
  end

  def strip_comments css
    css.gsub(%r{/\* .*? \*/\s*[\n\r]*}mix, '')
  end

  def extract_imports css
    imports = []

    fixed_css = css.gsub(IMPORTS_REGEXP) do
      imports << $LAST_MATCH_INFO[:url]
      nil
    end

    [imports, fixed_css]
  end
end
