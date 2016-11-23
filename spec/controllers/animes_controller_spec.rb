describe AnimesController do
  let(:anime) { create :anime }
  include_examples :db_entry_controller, :anime

  describe '#show' do
    let(:anime) { create :anime, :with_topics }

    describe 'id' do
      before { get :show, id: anime.id }
      it { expect(response).to redirect_to anime_url(anime) }
    end

    describe 'to_param' do
      before { get :show, id: anime.to_param }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#characters' do
    let(:anime) { create :anime, :with_character }
    before { get :characters, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#staff' do
    let(:anime) { create :anime, :with_staff }
    before { get :staff, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#files' do
    context 'authenticated' do
      include_context :authenticated, :user
      before { get :files, id: anime.to_param }
      it { expect(response).to have_http_status :success }
    end

    context 'guest' do
      before { get :files, id: anime.to_param }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#similar' do
    let!(:similar_anime) { create :similar_anime, src: anime }
    before { get :similar, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#screenshots' do
    let!(:screenshot) { create :screenshot, anime: anime }

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :screenshots, id: anime.to_param }
      it { expect(response).to have_http_status :success }
    end

    context 'guest' do
      before { get :screenshots, id: anime.to_param }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#videos' do
    let!(:video) { create :video, :confirmed, anime: anime }

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :videos, id: anime.to_param }
      it { expect(response).to have_http_status :success }
    end

    context 'guest' do
      before { get :videos, id: anime.to_param }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#related' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    before { get :related, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#chronology' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    before { get :chronology, id: anime.to_param }
    after { BannedRelations.instance.clear_cache! }
    it { expect(response).to have_http_status :success }
  end

  describe '#franchise' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    before { get :franchise, id: anime.to_param }
    after { BannedRelations.instance.clear_cache! }
    it { expect(response).to have_http_status :success }
  end

  describe '#art' do
    before { get :art, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#images' do
    before { get :images, id: anime.to_param }
    it { expect(response).to redirect_to art_anime_url(anime) }
  end

  describe '#cosplay' do
    let(:cosplay_gallery) { create :cosplay_gallery }
    let!(:cosplay_link) { create :cosplay_gallery_link, cosplay_gallery: cosplay_gallery, linked: anime }
    before { get :cosplay, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#favoured' do
    let!(:favoured) { create :favourite, linked: anime }
    before { get :favoured, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#clubs' do
    let(:club) { create :club, :with_topics, :with_member }
    let!(:club_link) { create :club_link, linked: anime, club: club }
    before { get :clubs, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#summaries' do
    let(:anime) { create :anime, :with_topics }
    let!(:comment) { create :comment, :summary, commentable: anime.topic(:ru) }
    before { get :summaries, id: anime.to_param }

    it { expect(response).to have_http_status :success }
  end

  describe '#resources' do
    before { get :resources, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#other_names' do
    before { get :other_names, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#episode_torrents' do
    before { get :episode_torrents, id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#autocomplete' do
    let(:anime) { build_stubbed :anime }
    let(:phrase) { 'qqq' }

    before { allow(Animes::AutocompleteQuery).to receive(:call).and_return [anime] }
    before { get :autocomplete, search: 'Fff' }

    it do
      expect(collection).to eq [anime]
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end
end
