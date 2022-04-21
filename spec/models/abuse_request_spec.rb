describe AbuseRequest do
  describe 'relations' do
    it { is_expected.to belong_to(:comment).optional }
    it { is_expected.to belong_to(:topic).optional }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:approver).optional }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(*Types::AbuseRequest::Kind.values) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:reason).is_at_most(4096) }

    context 'accepted' do
      subject { build :abuse_request, state: 'accepted' }
      it { is_expected.to validate_presence_of :approver }
    end

    context 'rejected' do
      subject { build :abuse_request, state: 'rejected' }
      it { is_expected.to validate_presence_of :approver }
    end
  end

  context 'scopes' do
    let(:comment) { create :comment, user: user }

    describe 'pending' do
      let!(:offtop) { create :abuse_request, kind: :offtopic, comment: comment }
      let!(:abuse) { create :abuse_request, kind: :abuse, comment: comment }
      let!(:accepted) { create :accepted_abuse_request, kind: :offtopic, approver: user }

      it { expect(AbuseRequest.pending).to eq [offtop] }
    end

    describe 'abuses' do
      let!(:offtop) { create :abuse_request, kind: :offtopic, comment: comment }
      let!(:abuse) { create :abuse_request, kind: :abuse, comment: comment }

      it { expect(AbuseRequest.abuses).to eq [abuse] }
    end
  end

  describe 'aasm' do
    subject(:abuse_request) { create :abuse_request, user: user }

    describe '#take' do
      before { abuse_request.take user }
      its(:approver) { is_expected.to eq user }

      context 'comment' do
        subject { abuse_request.comment }
        its(:is_offtopic) { is_expected.to eq true }
      end
    end

    describe '#reject' do
      before { abuse_request.reject user }
      its(:approver) { is_expected.to eq user }

      context 'comment' do
        subject { abuse_request.comment }
        its(:is_offtopic) { is_expected.to eq false }
      end
    end
  end

  describe 'instance methods' do
    describe '#punishable?' do
      let(:abuse_request) { build :abuse_request, kind: kind }
      subject { abuse_request.punishable? }

      describe true do
        context 'abuse' do
          let(:kind) { 'abuse' }
          it { is_expected.to eq true }
        end

        context 'spoiler' do
          let(:kind) { 'spoiler' }
          it { is_expected.to eq true }
        end
      end

      describe false do
        context 'offtopic' do
          let(:kind) { 'offtopic' }
          it { is_expected.to eq false }
        end

        context 'summary' do
          let(:kind) { 'summary' }
          it { is_expected.to eq false }
        end
      end
    end

    describe '#target, #taget_type' do
      subject(:abuse_request) do
        build :abuse_request,
          comment: comment,
          topic: topic
      end
      let(:comment) { nil }
      let(:topic) { nil }

      subject 'comment' do
        let(:comment) { build :comment }

        its(:target) { is_expected.to eq comment }
        its(:target_type) { is_expected.to eq 'Comment' }
      end

      subject 'topic' do
        let(:topic) { build :topic }

        its(:target) { is_expected.to eq topic }
        its(:target_type) { is_expected.to eq 'Topic' }
      end
    end
  end

  describe 'permissions' do
    subject { Ability.new user }
    let(:abuse_request) { build :abuse_request }
    let(:user) { build_stubbed :user, roles: [role] }

    context 'forum_moderator' do
      let(:role) { :forum_moderator }
      it { is_expected.to be_able_to :manage, abuse_request }
    end

    context 'not forum_moderator' do
      roles = (
        Types::User::Roles.values -
        %i[forum_moderator - super_moderator - news_super_moderator - admin]
      )
      roles.each do |role_value|
        context role_value do
          let(:role) { role_value }
          it { is_expected.to_not be_able_to :manage, abuse_request }
          it { is_expected.to be_able_to :read, abuse_request }
        end
      end
    end
  end

  it_behaves_like :antispam_concern, :abuse_request
end
