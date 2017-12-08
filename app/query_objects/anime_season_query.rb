class AnimeSeasonQuery
  pattr_initialize :season, :klass

  def to_sql
    case season
      when 'ancient'
        "aired_on <= '%s 00:00:00'" % Date.new(1980)

      when /^([a-z]+)_(\d+)$/
        year = $2.to_i
        season = $1
        date_from = nil
        date_to = nil
        additional = ''

        case season
          when 'winter'
            date_from = Date.new(year-1, 12) - 8.days
            date_to = Date.new(year, 3) - 8.days
            additionals =
              if @klass == Anime
                "aired_on != '#{year}-01-01' or season = 'winter_#{year}'"
              else
                "aired_on != '#{year}-01-01'"
              end
            additional = " and (#{additionals})"

          when 'fall'
            date_from = Date.new(year, 9) - 8.days
            date_to = Date.new(year, 12) - 8.days

          when 'summer'
            date_from = Date.new(year, 6) - 8.days
            date_to = Date.new(year, 9) - 8.days

          when 'spring'
            date_from = Date.new(year, 3) - 8.days
            date_to = Date.new(year, 6) - 8.days

          else
            raise InvalidParameterError.new(:season, season)
        end
        "(aired_on >= '#{date_from}' and aired_on < '#{date_to}'#{additional})"

      when /^(\d+)$/
        "(aired_on >= '#{Date.new($1.to_i)}' and aired_on < '#{Date.new($1.to_i + 1)}')"

      when /^(\d+)_(\d+)$/
        "(aired_on >= '#{Date.new($1.to_i)}' and aired_on < '#{Date.new($2.to_i + 1)}')"

      when /^(\d{3})x$/
        "(aired_on >= '#{Date.new($1.to_i * 10)}' and aired_on < '#{Date.new(($1.to_i + 1)*10)}')"

      else
        raise InvalidParameterError.new(:season, season)
    end
  end
end
