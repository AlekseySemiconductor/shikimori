describe Forum do
  describe 'relations' do
    it { is_expected.to have_many :topics }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :permalink }
  end

  describe 'instance methods' do
    describe '#name' do
      subject { forum.name }
      let(:forum) { build :forum }

      context 'ru' do
        include_context :stub_locale, :ru
        it { is_expected.to match(/форум/) }
      end

      context 'en' do
        include_context :stub_locale, :en
        it { is_expected.to match(/forum/) }
      end
    end
  end
end
