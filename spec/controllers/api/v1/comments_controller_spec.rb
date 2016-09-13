describe Api::V1::CommentsController do
  let(:user) { create :user, :user, :day_registered }
  let(:topic) { create :topic, user: user }
  let(:comment) { create :comment, commentable: topic, user: user }

  describe '#show', :show_in_doc do
    before { get :show, id: comment.id, format: :json }

    it do
      expect(json).to have_key :user
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#index', :show_in_doc do
    let!(:comment_1) { create :comment, user: user, commentable: user }
    let!(:comment_2) { create :comment, user: user, commentable: user }

    before do
      get :index,
        commentable_type: User.name,
        commentable_id: user.id,
        page: 1,
        limit: 10,
        desc: '1',
        format: :json
    end

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#create' do
    include_context :authenticated, :user
    let(:params) do
      {
        commentable_id: topic.id,
        commentable_type: Topic.name,
        body: body,
        is_offtopic: true,
        is_summary: true
      }
    end

    before do
      post :create,
        frontend: is_frontend,
        comment: params,
        format: :json
    end

    context 'success' do
      let(:body) { 'x' * Comment::MIN_SUMMARY_SIZE }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :successful_resource_change, :frontend
      end

      context 'api', :show_in_doc do
        let(:is_frontend) { false }
        it_behaves_like :successful_resource_change, :api
      end
    end

    context 'failure' do
      let(:body) { '' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :failed_resource_change
      end

      context 'api' do
        let(:is_frontend) { false }
        it_behaves_like :failed_resource_change
      end
    end
  end

  describe '#update' do
    include_context :authenticated, :user
    let(:params) { { body: body } }

    before do
      patch :update,
        id: comment.id,
        frontend: is_frontend,
        comment: params,
        format: :json
    end

    context 'success' do
      let(:body) { 'blablabla' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :successful_resource_change, :frontend
      end

      context 'api', :show_in_doc do
        let(:is_frontend) { false }
        it_behaves_like :successful_resource_change, :api
      end
    end

    context 'failure' do
      let(:body) { '' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :failed_resource_change
      end

      context 'api' do
        let(:is_frontend) { false }
        it_behaves_like :failed_resource_change
      end
    end
  end

  describe '#destroy' do
    include_context :authenticated, :user
    let(:make_request) { delete :destroy, id: comment.id, format: :json }

    context 'success', :show_in_doc do
      before { make_request }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
        expect(json[:notice]).to eq 'Комментарий удален'
      end
    end

    context 'forbidden' do
      let(:comment) { create :comment, commentable: topic }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
