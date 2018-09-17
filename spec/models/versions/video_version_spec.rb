describe Versions::VideoVersion do
  describe '#action' do
    let(:version) { build :video_version, item_diff: { action: 'upload' } }
    it { expect(version.action).to eq Versions::VideoVersion::Action[:upload] }
  end

  describe '#video' do
    let(:video) { create :video }

    let(:version) { build :video_version, item_diff: { videos: [video.id] } }
    it { expect(version.video).to eq video }
  end

  describe '#apply_changes' do
    let(:version) { build :video_version, item_diff: { action: action, videos: [video.id] } }

    context 'upload' do
      let(:video) { create :video, :uploaded }
      let(:action) { 'upload' }
      subject! { version.apply_changes }

      it { expect(video.reload).to be_confirmed }
    end

    context 'delete' do
      let(:video) { create :video, :confirmed }
      let(:action) { 'delete' }
      subject! { version.apply_changes }

      it { expect(video.reload).to be_deleted }
    end

    context 'unknown action' do
      let(:video) { build_stubbed :video }
      let(:action) { 'zzz' }
      it { expect { version.apply_changes }.to raise_error Dry::Types::ConstraintError }
    end
  end

  describe '#rollback_changes' do
    let(:version) { build :video_version }
    it { expect { version.rollback_changes }.to raise_error NotImplementedError }
  end

  describe '#cleanup' do
    let(:video) { create :video }
    let(:version) do
      build :video_version,
        item_diff: {
          action: action,
          videos: [video.id]
        }
    end

    subject! { version.cleanup }

    context 'upload' do
      let(:action) { 'upload' }
      it { expect { video.reload }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'delete' do
      let(:action) { 'delete' }
      it { expect(video.reload).to be_persisted }
    end
  end
end
