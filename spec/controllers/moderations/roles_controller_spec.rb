describe Moderations::RolesController do
  describe '#index' do
    include_context :authenticated, :user
    subject! { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    include_context :authenticated, :user
    subject! { get :show, params: { id: role } }

    context 'invalid role' do
      let(:role) { 'zxc' }
      it { expect(response).to redirect_to moderations_roles_url }
    end

    context 'valid role' do
      let(:role) { 'admin' }
      it do
        expect(collection).to eq [user_admin]
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#update' do
    include_context :authenticated, :forum_moderator
    let(:target_user) { user_admin }

    let(:make_request) do
      post :update,
        params: {
          id: role,
          user_id: target_user.id
        },
        format: :json
    end

    context 'permitted' do
      let(:role) { :censored_avatar }
      subject! { make_request }

      it do
        expect(resource).to be_persisted
        expect(resource).to be_auto_accepted
        expect(User.find(target_user.id)).to be_censored_avatar

        expect(json).to have_key :content
        expect(response).to have_http_status :success
      end
    end

    context 'not permitted' do
      let(:role) { :admin }
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
        expect(User.find(target_user.id)).to_not be_censored_avatar
      end
    end
  end

  describe '#destroy' do
    include_context :authenticated, :forum_moderator
    let(:target_user) { create :user, roles: %i[censored_avatar] }

    let(:make_request) do
      delete :destroy,
        params: {
          id: role,
          user_id: target_user.id
        },
        format: :json
    end

    context 'permitted' do
      let(:role) { :censored_avatar }
      subject! { make_request }

      it do
        expect(resource).to be_persisted
        expect(resource).to be_auto_accepted
        expect(User.find(target_user.id)).to_not be_censored_avatar

        expect(json).to have_key :content
        expect(response).to have_http_status :success
      end
    end

    context 'not permitted' do
      let(:role) { :admin }
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
        expect(User.find(target_user.id)).to be_censored_avatar
      end
    end
  end
end
