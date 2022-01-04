describe Comment::Move do
  subject! do
    described_class.call(
      comment: comment,
      to: site_rules_topic,
      basis: basis
    )
  end
  let(:comment) do
    create :comment,
      commentable: offtopic_topic,
      body: reply_sample
  end
  let(:basis) { build_stubbed :comment }
  let(:reply_samples) do
    [
      "[quote=#{basis.id}]",
      "[quote=#{basis.id};#{user.id};test]",
      "[quote=c#{basis.id};#{user.id};test]",
      # "[comment=#{basis.id}]",
      # ">?c99999;#{user.id};testb"
    ]
  end
  let(:reply_sample) { reply_samples.sample }
  let(:reply_converted) do
    [
      "[quote=#{basis.id}]",
      "[quote=t#{site_rules_topic.id};#{user.id};test]",
      "[quote=t#{site_rules_topic.id};#{user.id};test]",
      # "[topic=#{site_rules_topic.id}]",
      # ">?t#{site_rules_topic.id};#{user.id};test"
    ]
  end

  it do
    expect(comment.reload.commentable).to eq site_rules_topic
    expect(comment.body).to eq reply_converted[reply_samples.index(reply_sample)]
  end
end
