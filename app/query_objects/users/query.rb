class Users::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch
    new User.order(last_online_at: :desc)
  end

  def search phrase
    return self if phrase.blank?

    chain Search::User.call(
      scope: @scope,
      phrase: phrase,
      ids_limit: SEARCH_LIMIT
    )
  end

  def id value
    return self if value.to_i.zero?

    chain @scope.where(id: value)
  end

  def current_sign_in_ip ip
    return self if ip.blank?

    chain @scope.where(current_sign_in_ip: ip)
  end

  def last_sign_in_ip ip
    return self if ip.blank?

    chain @scope.where(last_sign_in_ip: ip)
  end

  def created_on date
    return self if date.blank?

    chain @scope
      .except(:order)
      .where(
        'created_at >= ? and created_at <= ?',
        Time.zone.parse(date).beginning_of_day,
        Time.zone.parse(date).end_of_day
      )
      .order(:created_at)
  end
end
