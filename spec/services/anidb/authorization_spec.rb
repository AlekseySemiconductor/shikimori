# frozen_string_literal: true

describe Anidb::Authorization, :vcr do
  let(:service) { Anidb::Authorization.instance }

  describe '#cookie' do
    subject { service.cookie }
    use_vcr_cassette 'Anidb_Authorization/cookie'

    it do
      is_expected.to eq %w(
        adbautopass=zwsofsxfdnrzyxdj;
        adbautouser=naruto1451;
        adbsess=HeOtBhOHtFVJILxs;
        adbsessuser=naruto1451;
        adbss=740345-HeOtBhOH;
        adbuin=1491134069-bSaf;
        anidbsettings=%7B%22USEAJAX%22%3A1%7D;
      )
    end

    describe 'caching' do
      let(:cookies) { 'zzz' }
      before do
        allow(Rails.cache).to receive :write
        allow(service).to receive(:authorize).and_return cookies
      end
      before { subject }

      it do
        expect(Rails.cache)
          .to have_received(:write)
          .with Anidb::Authorization::CACHE_KEY, cookies, {}
      end
    end
  end

  describe '#refresh' do
    before do
      allow(Rails.cache).to receive :delete
      allow(service).to receive :cookie
    end
    before { service.refresh }

    it do
      expect(Rails.cache)
        .to have_received(:delete)
        .with Anidb::Authorization::CACHE_KEY
      expect(service).to have_received :cookie
    end
  end
end
