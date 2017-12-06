describe ShikiMailer do
  describe '#private_message_email' do
    subject(:mail) { ShikiMailer.private_message_email(message.id).deliver_now }

    let(:unsubscribe_link_key) { '123' }
    before do
      allow_any_instance_of(ShikiMailer)
        .to receive(:unsubscribe_link_key)
        .and_return unsubscribe_link_key
    end

    let(:from_user) do
      create :user, nickname: 'Randy'
    end
    let(:to_user) do
      create :user, nickname: 'Vasya', email: to_email, locale: to_user_locale
    end
    let(:to_user_locale) { :ru }
    let(:to_email) { 'test@gmail.com' }

    let(:read) { false }
    let(:message_body) { 'Hi, Vasya!' }
    let(:message) do
      create :message,
        read: read,
        to: to_user,
        from: from_user,
        body: message_body
    end

    context 'recipient uses ru locale' do
      let(:to_user_locale) { :ru }
      it do
        expect(mail.subject).to eq 'Личное сообщение'
        expect(mail.body.raw_source).to eq "
          #{to_user.nickname}, у вас 1 новое сообщение на shikimori.org от пользователя #{from_user.nickname}.
          Прочитать можно тут: https://test.host/#{to_user.nickname}/dialogs

          Отписаться от уведомлений можно по ссылке:
          https://test.host/messages/#{to_user.nickname}/#{unsubscribe_link_key}/Private/unsubscribe
        ".gsub(/^ +/, '').strip
      end
    end

    context 'recipient uses en locale' do
      let(:to_user_locale) { :en }
      it do
        expect(mail.subject).to eq 'Private message'
        expect(mail.body.raw_source).to eq "
          #{to_user.nickname}, you have 1 new message on shikimori.org from #{from_user.nickname}.
          Read the message: https://test.host/#{to_user.nickname}/dialogs

          To unsubscribe from notification emails click here:
          https://test.host/messages/#{to_user.nickname}/#{unsubscribe_link_key}/Private/unsubscribe
        ".gsub(/^ +/, '').strip
      end
    end

    context 'message is read' do
      let(:read) { true }
      it { is_expected.to be_nil }
    end

    context 'with generated email' do
      let(:to_email) { 'generated_123@mail.ru' }
      it { is_expected.to be_nil }
    end
  end

  describe '#reset_password_instructions' do
    subject(:mail) do
      ShikiMailer.reset_password_instructions(
        user,
        token,
        nil
      ).deliver_now
    end

    let(:email) { 'test@gmail.com' }
    let(:user) { build :user, nickname: 'Vasya', email: email, locale: user_locale }
    let(:user_locale) { :ru }
    let(:token) { 'token' }

    context 'recipient uses ru locale' do
      let(:user_locale) { :ru }
      it do
        expect(mail.subject).to eq 'Инструкция по сбросу пароля'
        expect(mail.body.raw_source).to eq "
          Привет!

          Кто-то активировал процедуру сброса пароля для вашего аккаунта на shikimori.org.

          Ваш логин - #{user.nickname}.

          Изменить пароль можно, перейдя по данной ссылке: https://test.host/users/password/edit?reset_password_token=#{token}


          Если вам пришло несколько писем о восстановлении пароля, то переходить на страницу сброса пароля нужно обязательно по ссылке из самого последнего письма.

          Если вы не запрашивали сброс пароля, то просто проигнорируйте это письмо.

          Ваш пароль не будет изменён до тех пор, пока вы не перейдёте по указанной выше ссылке.
        ".gsub(/^ +/, '').strip
      end
    end

    context 'recipient uses en locale' do
      let(:user_locale) { :en }
      it do
        expect(mail.subject).to eq 'Reset password instructions'
        expect(mail.body.raw_source).to eq "
          Hi!

          We have received a request to reset your account password on shikimori.org.

          Your acount login is #{user.nickname}.

          To reset you password click this link: https://test.host/users/password/edit?reset_password_token=#{token}


          If you didn't make a request to reset your password just ignore this message.

          Your password will not change until you click the link above.
        ".gsub(/^ +/, '').strip
      end
    end

    context 'with generated email' do
      let(:email) { 'generated_123@mail.ru' }
      it { is_expected.to be_nil }
    end
  end
end
