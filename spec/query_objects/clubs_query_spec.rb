describe ClubsQuery do
  let(:query) { ClubsQuery.new :ru }

  before { Timecop.freeze }
  after { Timecop.return }

  let(:user) { create :user }
  let!(:club_1) { create :club, :with_topics, id: 1 }
  let!(:club_2) { create :club, :with_topics, id: 2 }
  let!(:club_3) { create :club, :with_topics, id: 3 }
  let!(:club_4) { create :club, :with_topics, id: 4 }
  let!(:club_en) { create :club, :with_topics, id: 5, locale: :en }
  let!(:club_favoured) { create :club, :with_topics, id: ClubsQuery::FAVOURITES.max }

  before do
    club_1.members << user
    club_3.members << user
    club_4.members << user
    club_favoured.members << user
  end

  describe '#fetch' do
    subject { query.fetch page, limit, with_favourites }

    context 'without favourites' do
      let(:with_favourites) { false }
      let(:limit) { 2 }

      context 'first_page' do
        let(:page) { 1 }
        it { is_expected.to eq [club_1, club_3, club_4] }
      end

      context 'second_page' do
        let(:page) { 2 }
        it { is_expected.to eq [club_4] }
      end
    end

    context 'with favourite' do
      let(:with_favourites) { true }
      let(:limit) { 2 }

      context 'first_page' do
        let(:page) { 1 }
        it { is_expected.to eq [club_1, club_3, club_4] }
      end

      context 'second_page' do
        let(:page) { 2 }
        it { is_expected.to eq [club_4, club_favoured] }
      end
    end
  end

  describe '#favourite' do
    subject { query.favourite }
    it { is_expected.to eq [club_favoured] }
  end

  describe '#postload' do
    subject { query.postload page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { is_expected.to eq [[club_1, club_3], true] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { is_expected.to eq [[club_4], false] }
    end
  end
end
