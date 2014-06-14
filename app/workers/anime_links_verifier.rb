class AnimeLinksVerifier
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    find_anime_errors = bad_entries FindAnimeImporter
    hentai_anime_errors = bad_entries HentaiAnimeImporter

    raise "Ambiguous anime links found: #{find_anime_errors.join ', '}" if find_anime_errors.any?
    raise "Ambiguous anime links found: #{hentai_anime_errors.join ', '}" if hentai_anime_errors.any?
  end

  def bad_entries importer_klass
    service = importer_klass::SERVICE
    ignores = importer_klass.new.ignored_in_twice_match.to_a

    AnimeLink
      .where(service: service)
      .group_by(&:anime_id)
      .map {|k,v| [k, v.map(&:identifier) - ignores] }
      .select {|k,v| v.size > 1 }
      .map {|k,v| "#{k} (#{v.join ', '})" }
  end
end

