class BbCodes::Tags::PollTag
  include Singleton

  REGEXP = %r{
    \[poll=(\d+)\]
  }mix

  def format text
    text.gsub(
      REGEXP,
      '<div class="poll-placeholder not-tracked" id="\1" '\
        'data-track_poll="\1"></div>'
    )
  end
end
