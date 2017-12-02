describe EpisodeNotification::TrackEpisode do
  before { allow(Topics::Generate::News::EpisodeTopic).to receive :call }
  subject(:call) { described_class.call episode_notification }

  let!(:episode_notification) do
    create :episode_notification, :with_track_episode,
      anime: anime,
      episode: episode
  end
  let(:anime) do
    create :anime,
      episodes_aired: 2,
      episodes: 4,
      status: status,
      released_on: released_on
  end
  let(:status) { :ongoing }
  let(:released_on) { nil }

  context 'episode > anime.episodes' do
    let(:episode) { anime.episodes + 1 }
    it { expect { call }.to raise_error MissingEpisodeError }
  end

  context 'episode <= anime.episodes' do
    subject! { call }

    context 'episode == anime.episodes_aired' do
      let(:episode) { anime.episodes_aired }
      it { expect(Topics::Generate::News::EpisodeTopic).to_not have_received :call }
    end

    context 'episode < anime.episodes_aired' do
      let(:episode) { anime.episodes_aired - 1 }
      it { expect(Topics::Generate::News::EpisodeTopic).to_not have_received :call }
    end

    context 'episode > anime.episodes_aired' do
      let(:episode) { anime.episodes_aired + 1 }
      it do
        expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice
        Shikimori::DOMAIN_LOCALES.each do |locale|
          expect(Topics::Generate::News::EpisodeTopic)
            .to have_received(:call)
            .with(
              model: episode_notification.anime,
              user: episode_notification.anime.topic_user,
              locale: locale,
              aired_at: episode_notification.created_at,
              episode: episode_notification.episode
            )
        end
        expect(anime.reload.episodes_aired).to eq episode
      end

      describe 'old_released_anime?' do
        context 'old released anime' do
          let(:status) { :released }
          let(:released_on) { described_class::RELEASE_EXPIRATINO_INTERVAL.ago - 1.day }
          it { expect(Topics::Generate::News::EpisodeTopic).to_not have_received :call }
        end

        context 'old ongoing anime' do
          let(:status) { :ongoing }
          let(:released_on) { described_class::RELEASE_EXPIRATINO_INTERVAL.ago - 1.day }
          it { expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice }
        end

        context 'new released anime' do
          let(:status) { :released }
          let(:released_on) { described_class::RELEASE_EXPIRATINO_INTERVAL.ago + 1.day }
          it { expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice }
        end
      end
    end
  end
end
