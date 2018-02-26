describe BbCodes::Tags::SourceTag do
  subject { BbCodes::Tags::SourceTag.instance.format text }

  describe '#format' do
    let(:url) { 'http://site.com/site-url' }
    let(:text) { "[source]#{url}[/source]" }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <div class="b-source hidden"><span class="linkeable"
          data-href="#{url}">site.com</span></div>
        HTML
      )
    end

    context 'xss' do
      let(:text) { "[source]#{%w[< > " '].sample}[/source]" }
      it { is_expected.to eq text }
    end
  end
end
