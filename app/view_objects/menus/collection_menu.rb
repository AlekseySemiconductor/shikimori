class Menus::CollectionMenu < ViewObjectBase
  vattr_initialize :klass

  def url
    h.send "menu_#{klass.name.tableize}_url", rating: h.params[:rating], subdomain: false
  end

  def sorted_genres
    genres.sort_by { |v| [v.position || v.id, h.localized_name(v)] }
  end

  def genres
    "Repos::#{klass.base_class.name}Genres".constantize.instance.all
  end

  def studios
    Repos::Studios.instance.all
  end

  def publishers
    Repos::Publishers.instance.all
  end

  def kinds
    return [] if klass == Ranobe
    allowed_kinds.map { |kind| Titles::KindTitle.new kind, klass }
  end

  def statuses
    [
      Titles::StatusTitle.new(:anons, klass),
      Titles::StatusTitle.new(:ongoing, klass),
      Titles::StatusTitle.new(:released, klass),
      Titles::StatusTitle.new(:latest, klass),
    ]
  end

  def seasons
    [
      Titles::SeasonTitle.new(3.months.from_now, :season_year, klass),
      Titles::SeasonTitle.new(Time.zone.now, :season_year, klass),
      Titles::SeasonTitle.new(3.months.ago, :season_year, klass),
      Titles::SeasonTitle.new(6.months.ago, :season_year, klass),
      Titles::SeasonTitle.new(Time.zone.now, :year, klass),
      Titles::SeasonTitle.new(1.year.ago, :year, klass),
      Titles::SeasonTitle.new(2.years.ago, :years_2, klass),
      Titles::SeasonTitle.new(4.years.ago, :years_5, klass),
      Titles::SeasonTitle.new(
        9.years.ago,
        :"years_#{Time.zone.today.year - 2000 - 8}",
        klass
      ),
      Titles::SeasonTitle.new(Date.parse('1995-01-01'), :decade, klass),
      Titles::SeasonTitle.new(Date.parse('1985-01-01'), :decade, klass),
      Titles::SeasonTitle.new(nil, :ancient, klass)
    ]
  end

  def show_sorting?
    h.params[:controller] != 'recommendations' &&
      h.params[:search].blank? && h.params[:q].blank?
  end

  def anime?
    klass == Anime
  end

  def ranobe?
    klass == Ranobe
  end

private

  def allowed_kinds
    if h.params[:controller] == 'user_rates'
      klass.kind.values
    else
      klass.kind.values - [Ranobe::KIND]
    end
  end
end
