class AutoBannedError < Exception
  def initialize url
    super "auto-banned when trying to open \"#{url}\""
  end
end
