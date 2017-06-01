describe MessagesQuery do
  before { Message.antispam = false }
  let(:query) { MessagesQuery.new user, messages_type }

  let(:user) { build_stubbed :user }
  let(:user_2) { build_stubbed :user }
  let!(:private) do
    create :message,
      kind: MessageType::Private,
      to: user,
      from: user_2
  end
  let!(:sent) do
    create :message,
      kind: MessageType::Private,
      to: user_2,
      from: user
  end
  let!(:news) do
    create :message,
      kind: MessageType::Anons,
      to: user,
      from: user_2
  end
  let!(:notification) do
    create :message,
      kind: MessageType::FriendRequest,
      to: user,
      from: user_2,
      read: true
  end

  describe '#fetch' do
    subject { query.fetch 1, 1 }

    context 'inbox' do
      let!(:private_2) do
        create :message,
          kind: MessageType::Private,
          to: user,
          from: user_2,
          is_deleted_by_to: true,
          read: false
      end
      let!(:private_3) do
        create :message,
          kind: MessageType::Private,
          to: user,
          from: user_2,
          read: true
      end
      let(:messages_type) { :inbox }

      it { is_expected.to have(2).items }
      its(:first) { is_expected.to eq private }
    end

    context 'private' do
      let!(:private_2) do
        create :message,
          kind: MessageType::Private,
          to: user,
          from: user_2,
          is_deleted_by_to: true,
          read: false
      end
      let!(:private_3) do
        create :message,
          kind: MessageType::Private,
          to: user,
          from: user_2,
          read: true
      end
      let(:messages_type) { :private }

      it { is_expected.to have(1).item }
      its(:first) { is_expected.to eq private }
    end

    context 'sent' do
      let!(:sent_2) do
        create :message,
          kind: MessageType::Private,
          to: user_2,
          from: user
      end
      let(:messages_type) { :sent }

      it { is_expected.to eq [sent_2, sent] }
    end

    context 'news' do
      let(:messages_type) { :news }
      it { is_expected.to have(1).item }
      its(:first) { is_expected.to eq news }
    end

    context 'notifications' do
      let!(:notification_2) do
        create :message,
          kind: MessageType::ClubRequest,
          to: user,
          from: user_2,
          id: notification.id * 10
      end
      let!(:notification_3) do
        create :message,
          kind: MessageType::ClubRequest,
          to: user,
          from: user_2,
          id: notification.id * 100
      end
      let(:messages_type) { :notifications }

      it { is_expected.to have(2).items }
      its(:first) { is_expected.to eq notification_3 }
    end
  end

  describe '#postload' do
    let!(:notification_2) do
      create :message,
        kind: MessageType::ClubRequest,
        to: user,
        from: user_2,
        id: notification.id * 10
    end
    let!(:notification_3) do
      create :message,
        kind: MessageType::ClubRequest,
        to: user,
        from: user_2,
        id: notification.id * 100
    end
    let(:messages_type) { :notifications }

    subject { query.postload 2, 1 }

    its(:first) { is_expected.to eq [notification_2] }
    its(:second) { is_expected.to eq true }
  end
end
