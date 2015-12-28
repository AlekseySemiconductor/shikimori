describe CalendarsQuery do
  let(:query) { CalendarsQuery.new }

  context 'common calendar' do
    let!(:anime_1) { create :anime, name: '1' }

    let!(:anime_2) { create :anime, :ongoing, name: '2', aired_on: 1.day.ago }
    let!(:anime_3) { create :anime, :ongoing, name: '3', duration: 20 }
    let!(:anime_4) { create :anime, :ongoing, :ova, name: '4' }
    let!(:anime_5) { create :anime, :ongoing, name: '5', episodes_aired: 0, aired_on: Time.zone.now - 1.day - 1.month }

    let!(:anime_6) { create :anime, :anons, name: '6', aired_on: 1.day.from_now }
    let!(:anime_7) { create :anime, :anons, name: '7', aired_on: 2.days.from_now }
    let!(:anime_8) { create :anime, :anons, name: '8', aired_on: 2.days.from_now }

    it { expect(query.send :fetch_ongoings).to eq [anime_2, anime_3] }
    it { expect(query.send :fetch_anonses).to eq [anime_6, anime_7, anime_8] }

    it { expect(query.fetch).to eq [anime_2, anime_6, anime_7, anime_8] }
    it { expect(query.fetch_grouped).to have(3).items }
  end

  context 'before new year' do
    before { Timecop.freeze '28-12-2015' }
    after { Timecop.return }

    let!(:anime_1) { create :anime, :anons, aired_on: '01-01-2016' }
    let!(:anime_2) { create :anime, :anons, aired_on: '02-01-2016' }

    it { expect(query.fetch).to eq [anime_2] }
  end
end
