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

        context 'episode news' do
          let(:action) { 'episode' }
          it { is_expected.to eq 'Эпизод 1' }
        end

        context 'anons news' do
          let(:topic) { build :news_topic, :anime_anons }
          it { is_expected.to eq 'Анонс' }
        end

        context 'other news' do
          let(:action) { 'ongoing' }
          it { is_expected.to eq 'Онгоинг' }
        end
      end

      context 'not generated' do
        let(:generated) { false }
        it { is_expected.to eq '123' }
      end
    end
  end
end
