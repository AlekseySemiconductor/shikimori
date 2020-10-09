describe Comments::Replies do
  subject { described_class.call comment }

  let(:commentable_1) { build_stubbed :topic }
  let(:commentable_2) { build_stubbed :topic }
  let!(:comment) { create :comment, commentable: commentable_1 }
  let!(:reply_1_1) do
    create :comment, body: "[quote=#{comment.id};", commentable: commentable_1
  end
  let!(:reply_1_2) do
    create :comment, body: '[quote=9999999;', commentable: commentable_1
  end
  let!(:reply_1_3) do
    create :comment, body: "[quote=#{comment.id};", commentable: commentable_2
  end
  let!(:reply_2_1) do
    create :comment, body: "[quote=c#{comment.id};", commentable: commentable_1
  end
  let!(:reply_3_1) do
    create :comment, body: "[comment=#{comment.id}]", commentable: commentable_1
  end
  let!(:reply_4_1) do
    create :comment, body: ">?c#{comment.id};", commentable: commentable_1
  end

  it { is_expected.to eq [reply_2_1, reply_3_1, reply_4_1] }
end
