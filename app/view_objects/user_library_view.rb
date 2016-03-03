class UserLibraryView < ViewObjectBase
  vattr_initialize :user
  instance_cache :full_list, :truncated_list, :total_stats, :klass,
    :list_page, :page

  ENTRIES_PER_PAGE = {
    'lines' => 400,
    'posters' => 50
  }

  def each
    list_page.each do |entry|
      yield entry
    end
  end

  def any?
    list_page.any?
  end

  def list_page
    truncated_list.each do |status,list|
      list.stats = list_stats(full_list[status]) if list.stats
      list.size = full_list[status].size
    end
  end

  def counts
    user.stats.list_counts anime? ? :anime : :manga
  end

  def add_postloader?
    list_page_key = list_page.keys.last

    list_page.any? && (list_page.keys.last != full_list.keys.last ||
      (list_page[list_page_key].entries.size + list_page[list_page_key].index - 1) !=
        full_list[full_list.keys.last].size)
  end

  def total_stats
    stats = full_list
      .map { |_, v| list_stats v, false }
      .each_with_object({}) do |data, memo|
        data.each do |k, v|
          memo[k] ||= 0
          memo[k] += v
        end
      end

    stats[:days] = stats[:days].round(2) if stats[:days]
    stats.delete_if { |_, v| !(v > 0) }
    stats
  end

  def klass
    h.params[:list_type].capitalize.constantize
  end

  def anime?
    h.params[:list_type] == 'anime'
  end

  def full_list
    Rails.cache.fetch cache_key do
      UserListQuery.new(
        klass,
        user,
        h.params.merge(with_censored: true, order: sort_order)
      ).fetch
    end
  end

  def sort_order
    Animes::SortField.new('name', h).field
  end

  def list_view
    h.cookies['list_view'] || 'lines'
  end

private

  def truncated_list
    list = {}
    from = limit * (page - 1)
    to = from + limit

    # счётчик общего числа элементах
    i = 0
    # счётчик числа элементов в пределах группы
    j = 0

    full_list.each do |status,entries|
      j = 0

      entries.each do |entry|
        j += 1
        i += 1

        next if i <= from
        if i > to
          list[status].stats = nil if list[status]
          break
        end

        list[status] ||= OpenStruct.new entries: [], stats: {}, index: j
        list[status].entries.push entry
      end
    end

    list
  end

  # аггрегированная статистика по данным
  def list_stats data, reduce=true
    stats = {
      tv: data.sum { |v| v.target.anime? && v.target.kind_tv? ? 1 : 0 },
      movie: data.sum { |v| v.target.anime? && v.target.kind_movie? ? 1 : 0 },
      ova: data.sum { |v| v.target.anime? && (v.target.kind_ova? || v.target.kind_ona?) ? 1 : 0 },
      special: data.sum { |v| v.target.anime? && v.target.kind_special? ? 1 : 0 },
      music: data.sum { |v| v.target.anime? && v.target.kind_music? ? 1 : 0 },

      manga: data.sum { |v| v.target.manga? && (v.target.kind_manga? || v.target.kind_manhwa? || v.target.kind_manhua?) ? 1 : 0 },
      oneshot: data.sum { |v| v.target.manga? && v.target.kind_one_shot? ? 1 : 0 },
      novel: data.sum { |v| v.target.manga? && v.target.kind_novel? ? 1 : 0 },
      doujin: data.sum { |v| v.target.manga? && v.target.kind_doujin? ? 1 : 0 }
    }
    if anime?
      stats[:episodes] = data.sum(&:episodes)
    else
      stats[:chapters] = data.sum(&:chapters)
      stats[:volumes] = data.sum(&:volumes) if user.preferences.volumes_in_manga?
    end
    stats[:days] = (data.sum do |v|
      if anime?
        SpentTimeDuration.new(v).anime_hours v.target.episodes, v.target.duration
      else
        SpentTimeDuration.new(v).manga_hours v.target.chapters, v.target.volumes
      end
    end.to_f / 60 / 24).round(2)

    reduce ? stats.select { |_, v| v > 0 }.to_hash : stats
  end

  def cache_key
    [
      :user_list,
      :v5,
      user,
      Digest::MD5.hexdigest(h.request.url.gsub(/\.json$/, '').gsub(/\/page\/\d+/, '')),
      sort_order
      # h.user_signed_in? ? h.current_user.preferences.russian_names? : false
    ]
  end

  def page
    (h.params[:page] || 1).to_i
  end

  def limit
    ENTRIES_PER_PAGE[list_view]
  end
end
