describe BbCodes::Tags::TopicTag do
  subject { described_class.instance.format text }

  let(:text) { "[topic=#{topic.id}], test" }
  let(:topic) { create :topic, user: user, forum: animanga_forum }
  let(:url) { UrlGenerator.instance.topic_url topic }

  it do
    is_expected.to eq(
      "[url=#{url} bubbled b-mention]<s>@</s>#{user.nickname}[/url], test"
    )
  end

  context 'non existing topic' do
    let(:text) { "[topic=#{topic_id}], test" }
    let(:topic_id) { 98765 }
    let(:url) do
      UrlGenerator.instance.forum_topic_url(
        id: topic_id,
        forum: offtopic_forum
      )
    end

    it do
      is_expected.to eq(
        "<a href='#{url}' class='b-mention b-entry-404 bubbled'>" \
          "<s>@</s><del>[topic=#{topic_id}]</del></a>, test"
      )
    end
  end
end
