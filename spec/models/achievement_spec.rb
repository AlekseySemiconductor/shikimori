describe Achievement do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :neko_id }
    it { is_expected.to validate_presence_of :level }
    it { is_expected.to validate_presence_of :progress }
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:neko_id)
        .in(*Types::Achievement::NekoId.values)
    end
  end

  describe 'instance methods' do
    describe '#image, #border_color, #title, #text' do
      let(:neko) do
        NekoRepository.instance.find achievement.neko_id, achievement.level
      end
      let(:achievement) { build :achievement, neko_id: :animelist }

      it { expect(achievement.image).to eq neko.image }
      it { expect(achievement.border_color).to eq neko.border_color }
      it { expect(achievement.title).to eq neko.title_ru }
      it { expect(achievement.hint).to eq neko.hint }
      it { expect(achievement.text).to eq neko.text_ru }
    end
  end
end
