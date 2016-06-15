describe UserListParser do
  let(:parser) { UserListParser.new klass }
  let(:klass) { Anime }
  subject { parser.parse params }

  context 'mal' do
    let(:params) do
      {
        list_type: 'mal',
        data: '[{"id":1,"status":2,"episodes":3,"rewatches":4,"score":5.0,"name":"anime name"}]'
      }
    end
    it do
      is_expected.to eq [
        { id: 1, status: 2, episodes: 3, rewatches: 4, score: 5.0 }
      ]
    end
  end

  # context 'anime_planet', vcr: { cassette_name: 'anime_planet' } do
    # let(:klass) { Manga }
    # let(:params) {{ list_type: 'anime_planet', login: 'shikitest' }}
    # it { is_expected.to eq [{name: "Maid Sama!", status: 2, score: 6.0, year: 2005, volumes: 18, chapters: 0, id: nil}] }
  # end

  context 'xml' do
    let(:params) { { list_type: 'xml', file: xml } }
    let(:klass) { Manga }
    let(:manga_1) { create :manga, name: '07 Ghost' }
    let(:xml) do
      <<-XML.strip
<?xml version="1.0" encoding="UTF-8"?>
<myanimelist>
  <myinfo>
    <user_export_type>#{UserRatesImporter::MangaType}</user_export_type>
  </myinfo>
  <manga>
    <manga_mangadb_id>#{manga_1.id}</manga_mangadb_id>
    <my_read_volumes>0</my_read_volumes>
    <my_read_chapters>0</my_read_chapters>
    <my_score></my_score>
    <my_status>Plan to Read</my_status>
    <update_on_import>1</update_on_import>
    <my_comments>test</my_comments>
  </manga>
</myanimelist>
      XML
    end

    it do
      is_expected.to eq [{
        id: manga_1.id,
        volumes: 0,
        chapters: 0,
        rewatches: 0,
        status: 0,
        score: 0,
        text: 'test'
      }]
    end
  end

  context 'not supported list_type' do
    let(:params) { { list_type: 'hz' } }
    it { expect { subject }.to raise_error UnsupportedListType }
  end
end
