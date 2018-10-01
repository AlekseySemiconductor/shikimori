# TODO: переделать авторизацию на cancancan
class Moderations::AbuseRequestsController < ModerationsController
  load_and_authorize_resource only: %i[show]

  before_action :authenticate_user!,
    only: %i[index show take deny offtopic summary spoiler abuse]

  before_action :check_access, only: %i[take deny]

  LIMIT = 25

  def index
    og page_title: i18n_t('page_title.index')

    @processed = QueryObjectBase.new(processed_scope).paginate(@page, LIMIT)

    unless request.xhr?
      @moderators = moderators_scope
      @pending = pending_scope
    end
  end

  def show
    og noindex: true
    og page_title: i18n_t('page_title.show', id: @resource.id)
    breadcrumb i18n_t('page_title.index'), moderations_abuse_requests_url
  end

  def take
    @request = AbuseRequest.find params[:id]
    @request.take! current_user rescue StateMachine::InvalidTransition
    render json: {}
  end

  def deny
    @request = AbuseRequest.find params[:id]
    @request.reject! current_user rescue StateMachine::InvalidTransition
    render json: {}
  end

private

  def check_access
    raise CanCan::AccessDenied unless can? :manage, AbuseRequest
  end

  def processed_scope
    scope = AbuseRequest.where.not(state: :pending)

    unless can? :manage, AbuseRequest
      scope = scope
        .where(kind: %i[summary offtopic])
        .or(AbuseRequest.where(state: :accepted))
    end

    scope
      .includes(:user, :approver, comment: :commentable)
      .order(updated_at: :desc)
      .joins(comment: :topic)
      # .where(kind: :abuse) # for test purposes
      # .where(topics: { linked_type: Club.name })
  end

  def pending_scope
    AbuseRequest
      .pending
      .includes(:user, :approver, comment: :commentable)
      .order(:created_at)
  end

  def moderators_scope
    User
      .where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end
end
