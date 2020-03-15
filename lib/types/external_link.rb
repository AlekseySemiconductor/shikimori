module Types
  module ExternalLink
    SOURCES = %i[shikimori myanimelist smotret_anime hidden]

    Source = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*SOURCES)

    COMMON_KINDS = %i[
      official_site
      wikipedia
      anime_news_network
      myanimelist
    ]

    WATCH_ONLINE_KINDS = %i[
      crunchyroll
      wakanim
      amazon
      hidive
      hulu
      ivi
      kinopoisk_hd
      netflix
      okko
      youtube
    ]
    KINDS = {
      anime: COMMON_KINDS + %i[
        anime_db
        world_art
        kinopoisk
        kage_project
        smotret_anime
      ] + WATCH_ONLINE_KINDS + %i[twitter],
      manga: COMMON_KINDS + %i[
        readmanga
        mangaupdates
        mangafox
        mangachan
        mangahub
      ],
      ranobe: COMMON_KINDS + %i[twitter] + %i[ruranobe novelupdates]
    }

    INVISIBLE_KINDS = %i[myanimelist smotret_anime mangachan]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS.values.flatten.uniq)
  end
end
