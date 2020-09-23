describe BbCodes::Tags::VideoUrlTag do
  let(:tag) { BbCodes::Tags::VideoUrlTag.instance }

  subject { tag.format text }
  let(:text) { url }
  let(:url) { 'https://www.youtube.com/watch?v=og2a5lngYeQ' }

  it { is_expected.to eq "[video]#{url}[/video]" }

  context 'with text' do
    let(:text) { "zzz #{url}" }
    it { is_expected.to eq "zzz [video]#{url}[/video]" }
  end

  context 'wrapped in url' do
    let(:text) { "[url]https://www.youtube.com/watch?v=#{hash}[/url]" }
    it { is_expected.to eq text }
  end

  context 'wrapped in url' do
    let(:text) { "[url=#{url}]#{url}[/url]" }
    it { is_expected.to eq text }
  end
end
