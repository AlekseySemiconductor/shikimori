# TODO: переделать авторизацию на cancancan
class Moderations::BansController < ModerationsController
  load_and_authorize_resource except: %i[index]
  before_action :authenticate_user!, except: %i[index]
  layout false, only: %i[new]

  def show
    og noindex: true
    og page_title: i18n_t('page_title.show', id: @resource.id)
    breadcrumb i18n_t('page_title.index'), moderations_bans_url
  end

  def index # rubocop:disable MethodLength, AbcSize
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title.index')

    @moderators = User
      .where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }

    @bans = postload_paginate(params[:page], 25) do
      Ban.includes(:comment).order(created_at: :desc)
    end

    @site_rules = StickyTopicView.site_rules(locale_from_host)
    @club = Club.find_by(id: 917)&.decorate if ru_host?

    if can? :manage, AbuseRequest
      @declined = AbuseRequest
        .where(state: 'rejected', kind: %i[spoiler abuse])
        .order(id: :desc)
        .limit(15)
      @pending = AbuseRequest
        .where(state: 'pending')
        .includes(:user, :approver, comment: :commentable)
        .order(:created_at)
    end
  end

  def new
  end

  def create
    if @resource.save
      render :create, formats: :json
    else
      render json: @resource.errors.full_messages, status: :unprocessable_entity
    end
  rescue StateMachine::InvalidTransition
  end

private

  def ban_params
    params
      .require(:ban)
      .permit(:reason, :duration, :comment_id, :abuse_request_id, :user_id)
      .merge(moderator_id: current_user.id)
  end
end
