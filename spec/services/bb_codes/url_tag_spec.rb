describe BbCodes::UrlTag do
  subject { BbCodes::UrlTag.instance.format text }

  describe '#format' do
    let(:url) { 'http://site.com/site-url' }

    context 'without text' do
      let(:text) { "[url]#{url}[/url]" }

      it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a>" }

      context 'with class' do
        let(:text) { "[url aa bb]#{url}[/url]" }
        it { is_expected.to eq "<a class=\"b-link aa bb\" href=\"#{url}\">#{Url.new(url).without_http}</a>" }
      end

      context 'wo protocol url' do
        let(:url) { '//site.com/site-url' }
        let(:text) { "[url]#{url}[/url]" }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a>" }
      end

      context 'long url' do
        let(:url) { 'http://site.com/' + ('x' * BbCodes::UrlTag::MAX_SHORT_URL_SIZE) }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">site.com</a>" }
      end

      context 'shikimori url' do
        let(:url) { '//shikimori.org/animes' }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">/animes</a>" }
      end

      context 'encoded url' do
        let(:url) { '//shikimori.org/%D0%92%D0%B8%D0%BD%D0%BD%D0%B8' }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">/Винни</a>" }
      end

      context 'webm url tag' do
        let(:url) { 'http://html5demos.com/assets/dizzy.webm' }
        it { is_expected.to eq '[html5_video]http://html5demos.com/assets/dizzy.webm[/html5_video]' }
      end

      context 'webm url' do
        let(:text) { 'http://html5demos.com/assets/dizzy.webm' }
        it { is_expected.to eq '[html5_video]http://html5demos.com/assets/dizzy.webm[/html5_video]' }
      end
    end

    context 'with text' do
      let(:text) { "[url=#{url}]text[/url]" }

      it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">text</a>" }

      context 'with class' do
        let(:text) { "[url=#{url} aa]text[/url]" }
        it { is_expected.to eq "<a class=\"b-link aa\" href=\"#{url}\">text</a>" }
      end

      context 'without http' do
        let(:text) { '[url=site.com/site-url]text[/url]' }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">text</a>" }
      end

      describe 'relative path' do
        let(:text) { '[url=/test]test[/url]' }
        it { is_expected.to eq '<a class="b-link" href="/test">test</a>' }
      end
    end

    context 'just link' do
      context 'common case' do
        let(:text) { url }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a>" }
      end

      context 'without protocol' do
        let(:url) { '//site.com/site-url' }
        let(:text) { url }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a>" }
      end

      context 'with format' do
        let(:text) { "#{url}.json" }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}.json\">#{Url.new(url).without_http}.json</a>" }
      end

      context 'space format' do
        let(:text) { "#{url} test" }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a> test" }
      end

      context 'with dot' do
        let(:text) { "#{url}." }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a>." }
      end

      context 'with comma' do
        let(:text) { "#{url}, test" }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a>, test" }
      end

      context 'with brackets' do
        let(:text) { "(#{url})" }
        it { is_expected.to eq "(<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a>)" }
      end

      context 'with brackets #2' do
        let(:text) { "url(#{url});" }
        it { is_expected.to eq "url(<a class=\"b-link\" href=\"#{url}\">#{Url.new(url).without_http}</a>);" }
      end

      context 'in tag' do
        let(:text) { "[zz]#{url}[/zz]" }
        it { is_expected.to eq "[zz]#{url}[/zz]" }
      end

      context 'russian link' do
        let(:text) { 'http://www.hentasis.com/tags/%D3%F7%E8%F2%E5%EB%FC%ED%E8%F6%FB/' }
        it { is_expected.to eq '<a class="b-link" href="http://www.hentasis.com/tags/%D3%F7%E8%F2%E5%EB%FC%ED%E8%F6%FB/">www.hentasis.com</a>' }
      end

      context 'broken tag' do
        let(:link) { '[url=https://z.org/%B0«z»' }
        let(:text) { "[url=#{url}]#{link}[/url]" }
        it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{link}</a>" }
      end
    end
  end
end
