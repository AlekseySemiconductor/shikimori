describe DbEntries::MergeAsEpisode do
  let(:worker) { described_class.new }

  before { allow(DbEntry::MergeAsEpisode).to receive(:call).and_call_original }
  subject! { worker.perform type, from_id, to_id, episode, episode_field, user_id }

  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }

  let(:from_id) { anime_1.id }
  let(:to_id) { anime_2.id }
  let(:type) { 'Anime' }
  let(:episode) { 9 }
  let(:episode_field) { 'episodes' }
  let(:user_id) { user.id }

  it do
    is_expected.to_not be_nil

    expect(DbEntry::MergeAsEpisode)
      .to have_received(:call)
      .with(
        entry: anime_1,
        other: anime_2,
        episode: episode,
        episode_field: episode_field.to_sym
      )

    expect { anime_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(anime_2.reload).to be_persisted
  end

  context 'non existing id' do
    let(:from_id) { 987654321 }
    it { is_expected.to be_nil }
  end
end
