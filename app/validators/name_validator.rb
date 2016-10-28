class NameValidator < ActiveModel::EachValidator
  BANNED_NICKNAMES = %w(
    Youtoome
  )
  FORBIDDEN_NAMES = %r(
    \A(
      #{Forum::VARIANTS} |
      animes |
      mangas |
      contests |
      users |
      forum |
      info |
      styles |
      #{BANNED_NICKNAMES.join('|')}
    )\Z | ((
      \.css |
      \.js |
      \.jpg |
      \.jpeg |
      \.png |
      \.gif |
      \.css |
      \.js |
      \.ttf |
      \.eot |
      \.otf |
      \.svg |
      \.woff |
      \.php
    )\Z)
  )mix

  def validate_each record, attribute, value
    return unless value.kind_of? String

    is_taken = value =~ FORBIDDEN_NAMES ||
      presence(record, value, Club, :name) ||
      presence(record, value, User, :nickname)

    if is_taken
      message = options[:message] || I18n.t('activerecord.errors.messages.taken')
      record.errors[attribute] << message
    end

    if Banhammer.instance.abusive? value
      message = options[:message] || I18n.t('activerecord.errors.messages.abusive')
      record.errors[attribute] << message
    end
  end

private

  def presence record, value, klass, field
    query = if record.kind_of? klass
      klass.where.not(id: record.id)
    else
      klass
    end

    query.where("#{postgres_word_normalizer field} = #{postgres_word_normalizer '?'}", value).any?
  end

  def postgres_word_normalizer text
    "translate(lower(unaccent(#{text})), 'абвгдеёзийклмнопрстуфхць', 'abvgdeezijklmnoprstufхc`')"
  end
end
