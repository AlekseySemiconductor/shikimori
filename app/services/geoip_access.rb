# debian:
#   sudo apt-get install geoip-database geoip-database-contrib geoip-bin
# osx:
#   brew install geoip geoipupdate
#   geoipupdate

class GeoipAccess
  include Singleton

  # User.pluck(:last_sign_in_ip).uniq.map {|v| %x{geoiplookup #{v}}.fix_encoding[/GeoIP Country Edition: .*/] }.group_by {|v| v }.sort_by {|k,v| v.size }.each_with_object({}) {|(k,v),memo| memo[k] = v.size }
  ANIME_ONLINE_ALLOWED_COUNTRIES = Set.new [
    'RU', # Russian Federation
    'UA', # Ukraine
    'BY', # Belarus
    'KZ', # Kazakhstan
    'MD', # Moldova
    'LV', # Latvia
    'AZ', # Azerbaijan
    'EE', # Estonia
    'KG', # Kyrgyzstan
    'UZ', # Uzbekistan
    'LT', # Lithuania
    'RO', # Romania
    'TJ', # Tajikistan
  ]
  HZ = 'hz'

  WAKANIM_FORBIDDEN_COUNTRIES = Set.new [
    HZ,
    'RU',
    'JP',
    'FR'
  ]

  def anime_online_allowed? ip
    ANIME_ONLINE_ALLOWED_COUNTRIES.include? country_code(ip)
  end

  def wakanim_allowed? ip
    !WAKANIM_FORBIDDEN_COUNTRIES.include? country_code(ip)
  end

  def safe_ip ip
    ip.fix_encoding.gsub(/[^.\d]/, '')
  end

  def country_code ip
    safed_ip = safe_ip(ip)
    @codes ||= {}

    if @codes.include? safed_ip
      @codes[safed_ip]
    else
      @codes[safed_ip] = Rails.cache.fetch([:geo_ip, safed_ip]) do
        ask_geoip safed_ip
      end
    end
  end

private

  def ask_geoip ip
    %x{geoiplookup #{ip}}
      .fix_encoding[/GeoIP Country Edition: (\w+)/, 1] || HZ
  end
end
