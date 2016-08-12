using 'UserRates'
class UserRates.TrackUserRate
  MARK = 'not-tracked'

  constructor: (user_rate, $root) ->
    $root.find(".#{MARK}#{@_selector user_rate}")
      .removeClass(MARK)
      .data(model: user_rate)

  _selector: (user_rate) ->
    ".b-user_rate.#{user_rate.target_type.toLowerCase()}-#{user_rate.target_id}"
