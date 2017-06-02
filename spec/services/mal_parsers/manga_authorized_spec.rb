describe MalParsers::MangaAuthorized do
  let(:parser) { MalParsers::MangaAuthorized.new id }
  let(:id) { 1_394 }

  describe '#call', :vcr do
    subject { parser.call }

    it do
      is_expected.to eq(
        id: 1394,
        name: 'Shoujo Sect',
        image: 'https://myanimelist.cdn-dena.com/images/manga/2/111587.jpg',
        english: nil,
        japanese: '少女セクト',
        synonyms: [],
        kind: :manga,
        volumes: 2,
        chapters: 16,
        status: :released,
        aired_on: Date.parse('Tue, 17 Jun 2003'),
        released_on: Date.parse('Sat, 17 Sep 2005'),
        publishers: [{ id: 404, name: 'Comic Megastore' }],
        genres: [
          {
            id: 8,
            name: 'Drama'
          }, {
            id: 12,
            name: 'Hentai'
          }, {
            id: 22,
            name: 'Romance'
          }, {
            id: 23,
            name: 'School'
          }, {
            id: 34,
            name: 'Yuri'
          }
        ],
        score: 7.25,
        ranked: 0,
        popularity: 1228,
        members: 5583,
        favorites: 121,
        synopsis: "A story about a group of girls and their relationships at an all-girls school.\r\n\r\nShinobu Handa and Momoko Naitou know each other since childhood. Shinobu fell in love with Momoko from the first day they met. Now in High School, Momoko has forgotten about the past, but Shinobu hasn't. Both follow their own ways but Shinobu still hopes for Momoko to remember their promise from long ago. ",
        related: {
          side_story: [
            {
              id: 10667,
              name: 'Isuzu no Counter',
              type: :manga
            }
          ],
          adaptation: [
            {
              id: 4473,
              name: 'Shoujo Sect',
              type: :anime
            }
          ]
        },
        external_links: [
          {
            kind: 'wikipedia',
            url: 'http://ja.wikipedia.org/wiki/%E5%B0%91%E5%A5%B3%E3%82%BB%E3%82%AF%E3%83%88'
          }
        ]
      )
    end
  end
end
