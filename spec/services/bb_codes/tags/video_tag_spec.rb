describe BbCodes::Tags::VideoTag do
  let(:tag) { BbCodes::Tags::VideoTag.instance }

  describe '#format' do
    subject { tag.format text }

    let(:hash) { 'hGgCnkvHLJY' }
    let(:video) { create :video, url: "http://www.youtube.com/watch?v=#{hash}" }
    let(:text) { "[video=#{video.id}]" }
    it { is_expected.to include "data-href=\"//youtube.com/embed/#{hash}\" href=\"http://youtube.com/watch?v=#{hash}\"" }
  end
end
