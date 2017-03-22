class PersonDecorator < DbEntryDecorator
  decorates_finders

  rails_cache :best_works
  instance_cache :website,
    :flatten_roles, :all_roles, :groupped_roles, :roles_names, :works,
    :producer_favoured?, :mangaka_favoured?, :person_favoured?, :seyu_favoured?,
    :seyu_counts, :composer_counts, :producer_counts, :mangaka_counts

  ROLES = {
    seyu: Person::SEYU_ROLES,
    composer: ['Music', 'Theme Song Composition'],
    producer: ['Chief Producer', 'Producer', 'Director', 'Episode Director'],
    mangaka: Person::MANGAKA_ROLES,
    vocalist: ['Theme Song Performance']
  }
  FIXED_CUSTOM_MAIN_ROLES = {
    2337 => { producer: true }
  }

  def credentials?
    japanese.present? || object.name.present?
  end

  def url
    h.person_url object
  end

  def website_html
    if website_host.present?
      h.link_to website_host, website_url, rel: 'nofollow', class: 'b-link'
    end
  end

  def flatten_roles
    object.person_roles
      .pluck(:role)
      .map { |v| v.split(/, */) }
      .flatten
  end

  def groupped_roles
    flatten_roles.each_with_object({}) do |role, memo|
      role_name = I18n.t("role.#{role}", default: role)
      memo[role_name] ||= 0
      memo[role_name] += 1
    end.sort_by {|v| [-v.second, v.first] }
  end

  def favoured
    FavouritesQuery.new.favoured_by object, 12
  end

  def works
    all_roles
      .select { |v| v.anime || v.manga }
      .map { |v| RoleEntry.new((v.anime || v.manga).decorate, v.role) }
      .sort_by { |anime| sort_criteria anime }
      .reverse
  end

  def best_works
    anime_ids = object.animes.pluck(:id)
    manga_ids = object.mangas.pluck(:id)

    sorted_works = FavouritesQuery.new
      .top_favourite([Anime.name, Manga.name], 6)
      .where("(linked_type=? and linked_id in (?)) or (linked_type=? and linked_id in (?))",
        Anime.name, anime_ids, Manga.name, manga_ids)
      .map {|v| [v.linked_id, v.linked_type] }

    drop_index = 0
    while sorted_works.size < 6 && works.size > drop_index
      work = works.drop(drop_index).first
      mapped_work = [work.id, work.object.class.name]
      sorted_works.push mapped_work unless sorted_works.include?(mapped_work)
      drop_index += 1
    end

    selected_anime_ids = sorted_works.select {|v| v[1] == Anime.name }.map(&:first)
    selected_manga_ids = sorted_works.select {|v| v[1] == Manga.name }.map(&:first)
    (
      works.select {|v| v.anime? && selected_anime_ids.include?(v.id) } +
        works.select {|v| v.manga? && selected_manga_ids.include?(v.id) }
    ).sort_by {|v| sorted_works.index [v.id, v.object.class.name] }
  end

  def job_title
    if main_role? :producer
      i18n_t 'job_title.producer'
    elsif main_role? :mangaka
      i18n_t 'job_title.mangaka'
    elsif main_role? :composer
      i18n_t 'job_title.composer'
    elsif main_role? :vocalist
      i18n_t 'job_title.vocalist'
    elsif main_role? :seyu
      i18n_t 'job_title.seyu'
    elsif has_anime? && has_manga?
      i18n_t 'job_title.anime_manga_projects_participant'
    elsif has_anime?
      i18n_t 'job_title.anime_projects_participant'
    elsif has_manga?
      i18n_t 'job_title.manga_projects_participant'
    end
  end

  def occupation
    if has_anime? && has_manga?
      :anime_manga
    elsif has_anime?
      :anime
    elsif has_manga?
      :manga
    else
      raise ArgumentError, "Unknown occupation for #{self.class.name} #{to_param}"
    end
  end

  def role? role
    !roles_counts(role).zero?
  end

  def main_role? role
    return true if FIXED_CUSTOM_MAIN_ROLES.dig(object.id, role)

    other_roles = ROLES.keys
      .select { |v| v != role }
      .map { |v| roles_counts v }

     roles_counts(role) >= other_roles.max && !roles_counts(role).zero?
  end

  def seyu_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Seyu)
  end

  def producer_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Producer)
  end

  def mangaka_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Mangaka)
  end

  def person_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Person)
  end

  def url
    h.person_url object
  end

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/Person'
  end

  def best_character
    character_ids = object.character_ids
    fav_character = FavouritesQuery.new
      .top_favourite([Character.name], 1)
      .where(
        "linked_type=? and linked_id in (?)",
        Character.name,
        character_ids
      )
      .first.linked_id

    Character.find(fav_character)
  end

  def has_anime?
    all_roles.any? {|v| !v.anime_id.nil? }
  end

  def has_manga?
    all_roles.any? {|v| !v.manga_id.nil? }
  end

  def formatted_birthday
    I18n.l(birthday, format: :human).gsub('1901', '').strip
  end

private

  def all_roles
    object.person_roles.includes(:anime).includes(:manga).to_a
  end

  def roles_names
    groupped_roles.map {|k,v| k }
  end

  def roles_counts role
    flatten_roles.count {|v| ROLES[role].include? v }
  end

  def website_host
    begin
      URI.parse(website).host
    rescue
    end
  end

  def website_url
    if object.website.present?
      'http://%s' % object.website.sub(/^(https?:\/\/)?/, '')
    else
      nil
    end
  end

  def sort_criteria anime
    if sort_by_date?
      anime.aired_on || anime.released_on || 30.years.ago
    else
      anime.score && anime.score < 9.9 ? anime.score : -999
    end
  end

  def sort_by_date?
    h.params[:order_by] == 'date'
  end
end
