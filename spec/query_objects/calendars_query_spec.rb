describe CalendarsQuery do
  let(:query) { CalendarsQuery.new }
  let(:locale) { :ru }

  before { Timecop.freeze '28-12-2015 00:00:00' }
  after { Timecop.return }

  context 'common calendar' do
    let!(:anime_1) { create :anime, name: '1' }

    let!(:anime_2) { create :anime, :ongoing, name: '2', next_episode_at: 1.hour.from_now }
    let!(:anime_3) { create :anime, :ongoing, name: '3', duration: 20, next_episode_at: 2.hours.from_now }
    let!(:anime_4) { create :anime, :ongoing, :ova, name: '4' }
    let!(:anime_5) { create :anime, :ongoing, name: '5', episodes_aired: 0, aired_on: Time.zone.now - 1.day - 1.month }

    let!(:anime_6) { create :anime, :anons, name: '6', aired_on: 1.day.from_now }
    let!(:anime_7) { create :anime, :anons, name: '7', aired_on: 2.days.from_now }
    let!(:anime_8) { create :anime, :anons, name: '8', aired_on: 2.days.from_now }

    it do
      expect(query.send :fetch_ongoings).to eq [anime_2, anime_3]
      expect(query.send :fetch_anonses).to eq [anime_6, anime_7, anime_8]
      expect(query.fetch(locale)).to eq [anime_2, anime_3, anime_6, anime_7, anime_8]
      expect(query.fetch_grouped(locale)).to have(3).items
    end
  end

  context 'before new year' do
    let!(:anime_1) { create :anime, :anons, aired_on: '01-01-2016' }
    let!(:anime_2) { create :anime, :anons, aired_on: '02-01-2016' }

    it { expect(query.fetch(locale)).to eq [anime_2] }
  end
end
