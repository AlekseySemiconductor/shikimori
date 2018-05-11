# service must be run locally on developer machine
# to combine shikimori & mal_graph banned couplings
class Animes::GenerateBannedRelations < ServiceObjectBase
  IGNORED_MAL_COUPLING = %w[A18429 A6115]

  MAL_BANNED_FRANCHISES_URL = 'https://raw.githubusercontent.com/anime-plus/graph/master/data/banned-franchise-coupling.json'

  def self.call additional_data = []
    new(additional_data).call
  end

  def call additional_data
    cache = { 'A' => Anime, 'M' => Manga }
    data = combine(merge(fetch_mal, fetch_shiki, additional_data), cache)

    write_shiki data

    clear_rails_cache
    touch_restart

    data
  end

private

  def combine merged_data, cache
    merged_data.map do |ids|
      ids.map do |id|
        "#{id[0]}#{id[/\d+/]}###" + cache[id[0]].find(id[/\d+/]).name[0..60]
      end
    end
  end

  def write_shiki combined_data
    File.open(Animes::BannedRelations::CONFIG_PATH, 'w') do |v|
      v.write(
        combined_data
          .to_yaml
          .gsub(/^- -/, "-\n  -")
          .gsub('###', ' # ')
          .delete("'")
      )
    end
  end

  def clear_rails_cache
    Rails.cache.clear
  end

  def touch_restart
    `touch #{Rails.root.join 'tmp/restart.txt'}`
  end

  def merge shiki_data, mal_data, additional_data
    if additional_data.any? && additional_data.first.is_a?(String)
      additional_data = [additional_data]
    end

    if additional_data.any? && additional_data.first.is_a?(Numeric)
      raise "invalid additional_data: #{additional_data.to_json}"
    end

    (shiki_data + mal_data + additional_data).map(&:sort).sort.uniq
  end

  def fetch_shiki
    YAML.load_file(Animes::BannedRelations::CONFIG_PATH)
  end

  def fetch_mal
    JSON
      .parse(Network::FaradayGet.call(MAL_BANNED_FRANCHISES_URL).body)
      .map { |k, v| ([k] + v) }
      .reject { |group| (group & IGNORED_MAL_COUPLING).any? }
  end
end
