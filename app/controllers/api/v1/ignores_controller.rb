class Api::V1::IgnoresController < Api::V1Controller
  before_action :authenticate_user!

  before_action do
    doorkeeper_authorize! :friends_ignores if doorkeeper_token.present?
  end

  api :POST, '/ignores/:id', 'Create an ignore', deprecated: true
  description 'Requires `friends_ignores` oauth scope'
  def create
    @target_user = User.find(params[:id])
    current_user.ignores.create!(target: @target_user) unless current_user.ignores?(@target_user)
    render json: { notice: i18n_t('ignored', nickname: @target_user.nickname) }
  end

  api :DELETE, '/ignores/:id', 'Destroy an ignore', deprecated: true
  description 'Requires `friends_ignores` oauth scope'
  def destroy
    @user = User.find(params[:id])
    current_user.ignored_users.delete(@user)
    render json: { notice: i18n_t('not_ignored', nickname: @user.nickname) }
  end
end
