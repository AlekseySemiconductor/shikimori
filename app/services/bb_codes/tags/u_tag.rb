class BbCodes::Tags::UTag
  include Singleton

  def format text
    text.gsub(
      /\[u\] (.*?) \[\/u\]/mix,
      '<span style="text-decoration: underline;">\1</span>')
  end
end
