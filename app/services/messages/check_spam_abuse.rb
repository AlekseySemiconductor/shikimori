class Messages::CheckSpamAbuse
  include Translation
  method_object :message

  SPAM_LINKS = %r{
    cos30.ru/M=5j-N9 |
    aHR0cDovL3ByaW1hcnl4Lm5ldC9ncmVlaz9kbGM9a2ltb3Jp |
    goo.gl/KfKxKC |
    primaryx.net/quadro\?dlc=\w+
  }mix

  # rubocop:disable LineLength
  SPAM_PHRASES = [
    'Хорош качать уже) А то всё качаем,качаем',
    'Поднадоело читать, ищу напарника со мной в игру. Если за, то регайся и качай тут',
    'Вот прям затягивает и на моём ноуте идёт. Полно народу кстати бегает, регистрируйся',
    'Поднадоело читать, ищу напарника в игру. Если за, то регайся'
  ]
  # rubocop:enable LineLength

  def call
    if spam? @message
      message.errors.add :base, ban_text(@message)
      Users::BanSpamAbuse.perform_async @message.from_id
      NamedLogger.spam_abuse.info @message.attributes.to_yaml

      false
    else
      true
    end
  end

private

  def spam? message
    return false unless message.kind == MessageType::Private

    (
      message.body =~ SPAM_LINKS ||
      SPAM_PHRASES.any? { |phrase| message.body.include? phrase }
    )
  end

  def ban_text message
    i18n_t :ban_text,
      email: Shikimori::EMAIL,
      locale: message.from.locale.to_sym
  end
end
