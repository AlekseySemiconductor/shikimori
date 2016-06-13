class ClubsQuery < SimpleQueryBase
  decorate_page true
  pattr_initialize :locale

  FAVOURITE = [72, 19, 202, 113, 315, 293]

  def favourite
    clubs.where(id: FAVOURITE).decorate
  end

  def fetch page, limit, with_favourites = false
    query(with_favourites)
      .offset(limit * (page-1))
      .limit(limit + 1)
  end

  def query with_favourites
    if with_favourites
      clubs
    else
      clubs.where.not(id: FAVOURITE)
    end
  end

private

  def clubs
    Club
      .joins(:member_roles, :topics)
      .preload(:owner, :topics)
      .where(locale: locale)
      .group('clubs.id, entries.updated_at')
      .having('count(club_roles.id) > 0')
      .order('entries.updated_at desc, id')
  end
end
