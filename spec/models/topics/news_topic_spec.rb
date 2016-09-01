describe Topics::NewsTopic do
  describe 'enumerize' do
    it { is_expected.to enumerize(:action).in :anons, :ongoing, :released, :episode }
  end

  describe 'instance methods' do
    describe '#title' do
      let(:topic) { build :news_topic, generated: generated, action: action, title: '123', value: '1' }
      let(:action) { }
      subject { topic.title }

      context 'generated' do
        let(:generated) { true }

        context 'episode news topic' do
          let(:action) { 'episode' }
          it { is_expected.to eq 'Эпизод 1' }
        end

        context 'anons news topic' do
          let(:topic) { build :news_topic, :anime_anons }
          it { is_expected.to eq 'Анонс' }
        end

        context 'another news topic' do
          let(:action) { 'ongoing' }
          it { is_expected.to eq 'Онгоинг' }
        end
      end

      context 'not generated' do
        let(:generated) { false }
        it { is_expected.to eq '123' }
      end
    end

    describe '#full_title' do
      context 'generated' do
        let(:anime) { create :anime }
        let(:topic) { build :news_topic, :anime_anons, linked: anime }
        it { expect(topic.full_title).to eq "Анонс аниме #{anime.name}" }
      end

      context 'not generated' do
        let(:topic) { build :news_topic, generated: false }
        it { expect(topic.full_title).to eq topic.title }
      end
    end

    describe '#news_topic?' do
      let(:topic) { build :news_topic }
      it { expect(topic.news_topic?).to eq true }
    end
  end
end
